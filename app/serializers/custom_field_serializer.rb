class CustomFieldSerializer < ActiveModel::Serializer

  attributes :id,
    :label, :kind, :default_value, :editable

    belongs_to :user
    belongs_to :host

end
