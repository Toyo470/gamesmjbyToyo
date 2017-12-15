RoomManager = class("RoomManager")

function RoomManager:ctor()
    self.user_seat = 0
    self.uid_otherindex = {}
    self.user_data = {}

    self.group_round = 0
    self.group_total_round =0
end

function RoomManager:release()
  -- body
    self.user_seat = 0
    self.uid_otherindex = {}

    self.group_round = 0
    self.group_total_round = 0
end

function RoomManager:initialize( )
  -- body
end

function RoomManager:set_user_seat(uid,user_seat)
  -- body
  print("uid,user_seat--------------",uid,user_seat)
 	self.user_seat = user_seat
  self.uid_otherindex[uid] = 0
end

function RoomManager:get_user_seat( )
  -- body
  return self.user_seat
end

function RoomManager:set_other_seat(uid,other_seat)
	-- body
  print("uid,user_seat--------------",uid,other_seat)
  local other_index = other_seat - self.user_seat
  if other_index < 0 then
    other_index = other_index + 5
  end
  

  self.uid_otherindex[uid] = other_index
end

function RoomManager:get_other_index( uid )
  -- body
  return self.uid_otherindex[uid]
  
end

function RoomManager:get_other_index_by_seat(seat)

    local other_index = seat - self.user_seat

    if other_index < 0 then
      other_index = other_index + 5
    end

    return other_index
end

function RoomManager:set_user_data( uid,data )
  -- body
  self.user_data[uid] = data
end

function RoomManager:get_user_data(uid)
  -- body
  return self.user_data[uid] or {}
end

function RoomManager:get_user()
  -- body
  return self.user_data or {}
end

function RoomManager:set_group_round( group_round, group_total_round)
  -- body
    self.group_round = group_round
    self.group_total_round = group_total_round
end

function RoomManager:get_group_round()
  -- body
    return self.group_round,self.group_total_round
end