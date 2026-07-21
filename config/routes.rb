Rails.application.routes.draw do
  # The assessment engine's optional JSON API (the engine holds no auth; fine for the MVP demo).
  mount KyufyCore::Engine => "/kyufy_core"

  # The ONE screen (SPEC §2): 壁打ち chat — intake form → verdict cards.
  root "assessments#new"
  resource :assessment, only: :create

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
