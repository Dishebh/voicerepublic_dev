class ParticipationsController < ApplicationController

  before_filter :store_location
  before_filter :authenticate_user!

  # This is somewhat f*ckd! Devise might redirect here if a currently
  # not signed in user clicks on a participate now button. For now
  # we'll simpy redirect to the venue.
  #
  # GET /participations
  # GET /participations.json
  def index
    redirect_to venue_path(:id => params[:participation][:venue_id])
  end

  # POST /participations
  # POST /participations.json
  def create
    params[:participation] ||= {}
    params[:participation][:venue_id] = params[:venue_id]

    @participation = Participation.new(params[:participation])
    @participation.user_id = current_or_guest_user.id

    respond_to do |format|
      if @participation.save
        format.html do
          # make avatars appear on participant's view
          @venue = @participation.venue

          # TODO get rid of JS eval
          if @venue.live?
            markup = render_to_string partial: 'venues/venue_show_avatar', locals: { user: current_or_guest_user }
            markup = markup.gsub('"', "'").gsub("\n", '')
            script = "$('.venue-participants').append(\"#{markup}\");Venue.initMote();Venue.sortParticipants();"
            PrivatePub.publish_to @venue.back_channel, script
          end

          # after join redirect to venue page
          redirect_to @venue
        end
      else
        format.html { redirect_to Venue.find(params[:participation][:venue_id]) }
      end
    end
  end

  # DELETE /participations/1
  # DELETE /participations/1.json
  def destroy
    @participation = current_or_guest_user.participations.find_by_venue_id(params[:venue_id])
    @participation.destroy

    respond_to do |format|
      format.html { redirect_to @participation.venue }
    end
  end

end