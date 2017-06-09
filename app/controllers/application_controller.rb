class ApplicationController < ActionController::API
  include Knock::Authenticable
  
  # concerns
  include Response
  include ExceptionHandler
end
