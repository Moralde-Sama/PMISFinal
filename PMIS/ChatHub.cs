using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;
using System.Threading.Tasks;

namespace PMIS
{
    public class ChatHub : Hub
    {
        public void sendToAll(string name, string message)
        {
            Clients.All.sendToAll(name, message);
        }

        public void sendToGroup(string name, string message, string profPath, string group)
        {
            Clients.Group(group).sendToGroup(name, message, profPath);
        }

        public override Task OnConnected()
        {
            return base.OnConnected();
        }
        public override Task OnDisconnected(bool stopCalled)
        {
            return base.OnDisconnected(stopCalled);
        }
        public async Task Join(string roomName)
        {
            await Groups.Add(Context.ConnectionId, roomName);
        }
        public Task LeaveRoom(string roomName)
        {
            return Groups.Remove(Context.ConnectionId, roomName);
        }
        
    }
}