

CardManager = class("CardManager")

function CardManager:ctor()
    self.user_seat = 0
    self.uid_otherindex = {}
end

function CardManager:release()
  -- body
    self.user_seat = 0
    self.uid_otherindex = {}
end

function CardManager:initialize( )
  -- body
end