namespace :fix do

  task :rebuild_housing_associations => :environment do

    def fix_housing(h, attendance)
      if (h.class == HousingRequest and attendance.needs_housing?) or
        (h.class == HousingProvision and attendance.providing_housing?)
        h.host = attendance.host
        h.attendance_type = attendance.class.name
        h.save_without_timestamping
      else
        h.destroy
      end
    end

    def fix(h)
      attendance = h.attendance
      if attendance.present?
        fix_housing(h, attendance)
      elsif h.attendance_id.present?
        attendance = Attendance.with_deleted.find_by_id(h.attendance_id)
        if attendance.present?
          fix_housing(h, attendance)
        end
      end

    end

    HousingRequest.all.each do |h|
      fix(h)
    end

    HousingProvision.all.each do |h|
      fix(h)
    end
  end

end