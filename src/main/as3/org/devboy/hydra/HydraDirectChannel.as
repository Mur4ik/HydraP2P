////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2012 RealEyes Media LLC.
//
////////////////////////////////////////////////////////////////////////////////
package org.devboy.hydra
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	
	import org.devboy.hydra.packets.HydraPacketEvent;
	import org.devboy.hydra.packets.IHydraPacket;
	import org.devboy.toolkit.net.NetStatusCodes;
	
	public class HydraDirectChannel extends HydraChannel
	{
		//-----------------------------------------------------------
		//  DECLARATIONS
		//-----------------------------------------------------------
		
		
		//-----------------------------------------------------------
		//  INIT
		//-----------------------------------------------------------
		public function HydraDirectChannel(hydraService : HydraService, channelId : String, specifier : GroupSpecifier, withAuthorization : Boolean, autoConnect : Boolean=true)
		{
			super(hydraService, channelId, specifier, withAuthorization, autoConnect);
		}
		
		
		//-----------------------------------------------------------
		//  CONTROL
		//-----------------------------------------------------------
		
		
		//-----------------------------------------------------------
		//  EVENT LISTENERS
		//-----------------------------------------------------------
		public function sendDirectPacket(packet : IHydraPacket, destinationPeerID : String ):void
		{
			//Construct the packet and message the same as a broadcast packet
			packet.userId = hydraService.user.uniqueId;
			packet.timestamp = new Date().getTime();
			var message : Object = new Object();
			message.userId = packet.userId;
			message.type = packet.type;
			message.timestamp = packet.timestamp;
			message.info = packet.info;
			message.senderPeerId = hydraService.netConnection.nearID;
			
			//Add in the group address as the destination
			message.destination = netGroup.convertPeerIDToGroupAddress( destinationPeerID );
			
			netGroup.sendToNearest( message, message.destination );
				
			dispatchEvent( new HydraPacketEvent(HydraPacketEvent.PACKET_SENT, packet));
		}
		
		override protected function netStatus( event : NetStatusEvent ) : void
		{
			var infoCode : String = event.info.code;
			//If we've received a directly routed message, check to see if it is for us. If not, pass it on.
			if( infoCode == NetStatusCodes.NETGROUP_ROUTING_SENDTO_NOTIFY )
			{
				if( event.info.fromLocal )
				{
					trace( infoCode + " in HydraDirectChannel" );
					dispatchEvent( event );
					receivePacket( event.info.message );
				}
				else
				{
					netGroup.sendToNearest( event.info.message, event.info.message.destination );
				}
			}
			else
			{
				super.netStatus( event );
			}
		}
		
		//-----------------------------------------------------------
		//  GETTERS/SETTERS
		//-----------------------------------------------------------	
	}
}