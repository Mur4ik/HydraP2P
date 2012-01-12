/*
 * Copyright 2010 (c) Dominic Graefen, devboy.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
package org.devboy.hydra.users
{
	import flash.events.EventDispatcher;
	
	import org.devboy.hydra.HydraChannel;
	import org.devboy.hydra.packets.HydraPacketEvent;
	import org.devboy.hydra.ping.PingPacket;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraUserTracker extends EventDispatcher
	{
		private var _users : Vector.<HydraUser>;
		private var _hydraChannel : HydraChannel;
		
		public function HydraUserTracker(hydraChannel:HydraChannel)
		{
			_hydraChannel = hydraChannel;
			super(this);
			init();
		}

		private function init() : void
		{
			_users = new Vector.<HydraUser>();
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_CONNECT, neighborEvent);
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_DISCONNECT, neighborEvent);
			_hydraChannel.addEventListener(HydraPacketEvent.PACKET_RECEIVED, packetEvent );
		}

		private function packetEvent(event : HydraPacketEvent) : void
		{
			switch( event.packet.type )
			{
				case PingPacket.TYPE:
					handlePingPacket(event.packet as PingPacket);
					break;
			}
		}

		private function handlePingPacket(packet : PingPacket) : void
		{
			var user : HydraUser = new HydraUser(packet.userName, packet.userId, new NetGroupNeighbor("", packet.senderPeerId) );
			addUser(user);
		}

		private function neighborEvent(event : NetGroupNeighborEvent) : void
		{
			switch(event.type)
			{
				case NetGroupNeighborEvent.NEIGHBOR_CONNECT:
					break;
				case NetGroupNeighborEvent.NEIGHBOR_DISCONNECT:
					removeNeighbor(event.netGroupNeighbor);
					break;	
			}
			// FIXME: Thinking that the PingPacket is being used to handle user volatility within the channel.
			//			problem is, there's no data in the ping packet indicating whether it's a user
			//			connecting or disconnecting. For now commenting this out and will need to revisit.
			//_hydraChannel.sendPacket( new PingPacket( _hydraChannel.hydraService.user.name ) );
		}

		private function removeNeighbor(netGroupNeighbor : NetGroupNeighbor) : void
		{
			var user : HydraUser = getUserByPeerId(netGroupNeighbor.peerId);
			if( user )
				removeUser( user );
		}
		
		public function addUser( user : HydraUser ) : void
		{
			var listedUser : HydraUser;
			for each(listedUser in _users)
				if( listedUser.uniqueId == user.uniqueId )
					return;

			_users.push(user);
			_hydraChannel.addMemberHint(user.neighborId.peerId);
			_hydraChannel.addNeighbor(user.neighborId.peerId);
			dispatchEvent( new HydraUserEvent(HydraUserEvent.USER_CONNECT, user));		
		}

		private function removeUser(user : HydraUser) : void
		{
			var i : int = 0;
			const l : int = _users.length;
			for(;i<l;i++)
			{
				if( _users[i] == user )
				{
					var removedUser : HydraUser = _users[i];
					_users.splice(i, 1);
					dispatchEvent(new HydraUserEvent(HydraUserEvent.USER_DISCONNECT, removedUser));
					break;			
				}
			}
		}
		
		public function getUserByPeerId( peerId : String ) : HydraUser
		{
			// FIXME: You can't have a user tracker based on Neighbor Announcements since as the group grows 
			//			not everyone is a neighbor. For now just stubbing in "Other User", commenting out 
			//			the for each logic, and always returning a user			
			var user : HydraUser = new HydraUser( "Other User" );
			//for each( user in _users )
				//if( user.neighborId && user.neighborId.peerId == peerId )
					return user;
			//return null;
		}

		public function get users() : Vector.<HydraUser>
		{
			return _users;
		}
		
		
	}
}
