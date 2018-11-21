class GeParticipantsController < ApplicationController
  include ExchangeParticipantable
  include GeParticipantFields
  before_action :campaign_sign_up

  expose :ge_participant
  expose :exchange_participantable, -> { ge_participant }
  expose :ep_fields, -> { ge_participant_fields }
  expose :campaign, lambda {
    Campaign.where(utm_source: params[:ge_participant][:utm_source],
                   utm_medium: params[:ge_participant][:utm_medium],
                   utm_campaign: params[:ge_participant][:utm_campaign],
                   utm_term: params[:ge_participant][:utm_term],
                   utm_content: params[:ge_participant][:utm_content])
            .first_or_create
  }

  private

  def campaign_sign_up
    params_filled &&
      ge_participant.exchange_participant.campaign = campaign
  end

  def params_filled
    params[:ge_participant][:utm_source] &&
      params[:ge_participant][:utm_medium] &&
      params[:ge_participant][:utm_campaign] &&
      params[:ge_participant][:utm_term] &&
      params[:ge_participant][:utm_content]
  end

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :preferred_destination,
      :spanish_level,
      :when_can_travel,
      :curriculum,
      english_level_attributes: [:english_level],
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password scholarity
        campaign_id cellphone_contactable
      ]
    )
  end

  def nested_params
    ActionController::Parameters.new(
      ge_participant: {
        preferred_destination: params[:ge_participant][:preferred_destination].to_i,
        when_can_travel: params[:ge_participant][:when_can_travel].to_i,
        spanish_level: params[:ge_participant][:spanish_level].to_i,
        curriculum: params[:ge_participant][:curriculum],
        exchange_participant_attributes: exchange_participant_params,
        english_level_attributes: english_level_params
      }
    )
  end

  def exchange_participant_params
    params[:ge_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity.to_s.to_i, :campaign_id, :cellphone_contactable)
  end

  def english_level_params
    params[:ge_participant]
      .slice(:english_level.to_s.to_i)
  end

  def scholarity_human_name
    ep_scholarity = ge_participant.exchange_participant.scholarity
    ExchangeParticipant.human_enum_name(:scholarity, ep_scholarity)
  end

  def utm_source
    ge_participant&.exchange_participant&.campaign&.utm_source
  end

  def utm_medium
    ge_participant&.exchange_participant&.campaign&.utm_medium
  end

  def utm_campaign
    ge_participant&.exchange_participant&.campaign&.utm_campaign
  end

  def utm_term
    ge_participant&.exchange_participant&.campaign&.utm_term
  end

  def utm_content
    ge_participant&.exchange_participant&.campaign&.utm_content
  end
end
