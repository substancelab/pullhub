/* global $ */
export default function pullRequestChannelHandler (socket, userId) {
  if ($('#pullrequest-fetch-info').length === 0) {
    return
  }

  let channel = socket.channel(`pull_request:${userId}`, {})
  channel.join()
    .receive('ok', resp => {
      updateList()
    })
    .receive('error', resp => { console.log('Unable to join', resp) })

  function updateList () {
    $('#pullrequest-fetch-info').show()
    channel.push('update_pull_requests', {})
  }

  channel.on('pull_requests_updated', payload => {
    payload.data.forEach((info) => {
      let content = info.rendered_pull_requests
      let $list = $(`#repository-pull-requests-${info.repository_id}`)
      $list.html(content)

      $list.closest(".pull-requests-container").toggleClass("hidden", $list.children().length == 0)
    })
    $('#pullrequest-fetch-info').hide()

    setTimeout(updateList, 120000)
  })

  window.addEventListener('keyup', function (e) {
    if (e.key === 'r') {
      updateList()
    }
  })

  return channel
}
