Config = {}

Config.RestrictedChannels = 10 -- channels that are encrypted (EMS, Fire and police can be included there) if we give eg 10, channels from 1 - 10 will be encrypted
Config.enableCmd = false --  /radio command should be active or not (if not you have to carry the item "radio") true / false

Config.RestrictedChannelPermissions = {
    ambulance = { 1, 2, 3, 4, 8 },
    police = { 1, 5, 6, 7, 8 },
    mecano = { 8 }
}

Config.messages = {

  ['not_on_radio'] = 'You are currently not on any radio',
  ['on_radio'] = 'You are currently on the radio: <b>',
  ['joined_to_radio'] = 'You joined the radio: <b>',
  ['restricted_channel_error'] = 'You can not join that encrypted channel',
  ['you_on_radio'] = 'You are already on the radio: <b>',
  ['you_leave'] = 'You left the radio: <b>'

}
