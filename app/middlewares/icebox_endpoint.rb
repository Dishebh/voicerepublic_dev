class IceboxEndpoint < Struct.new(:app, :opts)

  ROUTE = %r{/icebox/([\w-]+)/(\w+)}

  OK               = [200, {}, ['200 - OK']]
  NOT_FOUND        = [404, {}, ['404 - Not found']]
  COMPUTER_SAYS_NO = [740, {}, ['740 - Computer says no']]

  def call(env)
    logger = Logger.new(Rails.root.join(Settings.stream_stats.log_path))
    path = env['PATH_INFO']

    return app.call(env) unless env['REQUEST_METHOD'] == 'POST'
    return app.call(env) unless path.match(%r{\A/icebox/})

    _, token, action = path.match(ROUTE).to_a
    return app.call(env) unless _

    if action == 'stats' && !Rails.env.test?
      Faye.publish_to '/server/heartbeat', token: token
    end

    json = env['rack.input'].read
    return OK if action == 'stats' && !json.match(/"source"/)

    venue = Venue.find_by(client_token: token)
    return NOT_FOUND if venue.nil?


    case action.to_sym
    when :ready
      venue.public_ip_address = Settings.icecast.url.host ||
                                JSON.parse(json)['public_ip_address']
      return COMPUTER_SAYS_NO if venue.public_ip_address.nil?
      venue.complete_provisioning!

    when :connect
      venue.connect! unless venue.connected?

    when :disconnect
      venue.disconnect! if venue.can_disconnect?

    when :synced
      venue.synced!

    when :stats
      stats = IcecastStatsParser.call(json)
      # this produces the same order as StreamStat#values
      values = [venue.id] + stats.to_a.sort_by(&:first).map(&:last)
      logger.info(values.join(','))
      Faye.publish_to venue.channel, event: 'stats', stats: stats
      Faye.publish_to '/admin/stats', stats: stats, slug: venue.slug
      return OK

    when :icebox_output_connect
    when :icebox_output_disconnect
    when :icebox_output_error
    when :icebox_output_start
    when :icebox_output_stop

    else
      return [ 721, {}, ['721 - Known Unknowns', path] ]
    end

    Rails.logger.info '-> 200 OK'
    OK

    #for now remove the catch all errors here
    # rescue => e
    # Rails.logger.error(([e.message]+e.backtrace) * "\n")
    #  [ 722, {}, ['722 - Unknown Unknowns', e.message] ]
  end

end
