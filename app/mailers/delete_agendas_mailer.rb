class DeleteAgendasMailer < ApplicationMailer
  default from: 'from@example.com'

  def delete_agendas_mail(agenda)
    @agenda = agenda
    mail to: @agenda.team.members.map(&:email).join(","), subject: 'アジェンダの削除'
  end
end
