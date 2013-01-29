class Setting < Settingslogic
  source "config/settings.yml"
  namespace ENV["RACK_ENV"]
end