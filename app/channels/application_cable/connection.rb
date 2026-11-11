module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # Guests may connect too, so they can watch auction prices live.
    # Turbo stream names are signed, so a guest can only follow streams rendered on pages they can see.
    def connect
      self.current_user = Session.find_by(id: cookies.signed[:session_id])&.user
    end
  end
end
