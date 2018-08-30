using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;
using System.Threading.Tasks;
using PMIS.Controllers;

namespace PMIS
{
    public class ChatHub : Hub
    {
        AccountController account = new AccountController();   

        public void sendToAll(string name, string message)
        {
            Clients.All.sendToAll(name, message);
        }

        public void sendToGroup(string name, string message, string profPath, string group)
        {
            Clients.Group(group).sendToGroup(name, message, profPath);
        }

        public void saveConnectionId()
        {
            string connectionId = Context.ConnectionId;
            Clients.Client(Context.ConnectionId).ConnectionId(connectionId);
        }

        public override Task OnConnected()
        {
            //account.saveConnectionId(Context.ConnectionId);
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