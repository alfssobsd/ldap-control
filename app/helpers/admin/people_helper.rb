module Admin::PeopleHelper
  def is_active_employeetype(params, value)
    if params[:employeetype].blank? and value == 'staff'
      "active"
    elsif params[:employeetype] == value
      "active"
    end
  end
end
