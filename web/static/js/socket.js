import {Socket} from 'phoenix'

export default {
  connect(userToken){
    if (userToken) {
      let socket = new Socket('/socket', {params: {token: userToken}})
      socket.connect()
      return socket
    }
  }
}
