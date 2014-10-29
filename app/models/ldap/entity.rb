class Ldap::Entity < Ldap::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  include ActiveRecord::AttributeMethods::Serialization
  extend ActiveModel::Naming


  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes.delete(:validation_context)
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def persisted?
    false
  end

  def save

  end

  def mapping(result)
    attributes.each do |name|
      if self.class::ARRAY_ATTR.include?(name)
        if result[name].blank?
          send("#{name}=", [""])
        else
          send("#{name}=", result[name])
        end
      elsif not result[name].first.blank?
        send("#{name}=", result[name].first.force_encoding("UTF-8"))
      else
        send("#{name}=", "")
      end
    end
    self
  end

  def self.mapping_array(result_list)
    array_obj_list = []
    result_list.each do |item|
      obj = new
      obj.mapping(item)
      array_obj_list << obj
    end
    array_obj_list
  end

end