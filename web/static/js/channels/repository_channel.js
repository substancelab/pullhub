/* global $ */
export default function repositoryChannelHandler (socket, userId) {
  let channel = socket.channel(`repository:list:${userId}`, {})
  channel.join()
    .receive('ok', resp => {
      updateList()
    })
    .receive('error', resp => { console.log('Unable to join', resp) })

  function updateList () {
    $('#repository-fetch-info').show()
    channel.push('update_repositories', {})
  }

  channel.on('repositories_updated', payload => {
    $('#repositories-table tbody').html(payload.data)
    $('#repository-fetch-info').hide()

    setTimeout(updateList, 60000)
  })

  return channel
}
