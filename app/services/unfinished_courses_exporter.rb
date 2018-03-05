require "csv"

class UnfinishedCoursesExporter

  def initialize(org)
    @org = org
  end

  def to_csv
    users = User.includes(:roles).where(organization_id: @org).order(:email)
    CSV.generate do |csv|
      csv << ["Email", "Program Name", "Course", "Course Started At"]
      users.each do |user|
        if user.reportable_role?(@org)
          user.course_progresses.each do |cp|
            unless cp.complete?
              program_name = user.program.present? ? user.program.program_name : ""
              values = [user.email, program_name, cp.course.title, cp.created_at.strftime("%m-%d-%Y")]
              csv.add_row values
            end
          end
        end
      end
    end
  end

end