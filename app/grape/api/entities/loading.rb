class API::Entities::Loading < Grape::Entity
  expose :loading_kind
  expose :human_loading_kind
  expose :value
end
