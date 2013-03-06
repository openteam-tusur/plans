class API::Entities::Loading < Grape::Entity
  expose :loading_kind
  expose :loading_kind_text
  expose :value
end
