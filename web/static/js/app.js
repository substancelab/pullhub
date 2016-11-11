import 'phoenix_html'

import socketConnector from './socket'

import startRepositoryChannel from './channels/repository_channel'

let userId = $("meta[name='user_id']").attr('content')
let userToken = $("meta[name='user_token']").attr('content')

let socket = socketConnector.connect(userToken)
startRepositoryChannel(socket, userId)
