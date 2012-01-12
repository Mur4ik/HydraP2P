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
package org.devboy.hydra.packets
{
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraPacketFactory
	{
		private var _creators : Vector.<IHydraPacketCreator>;
		
		public function HydraPacketFactory()
		{
			init();
		}

		private function init() : void
		{
			_creators = new Vector.<IHydraPacketCreator>();
		}
		
		public function addPacketCreator( creator : IHydraPacketCreator ) : void
		{
			if( !containsPacketCreatorForType(creator.packetType) )
				_creators.push(creator);
		}
		
		private function containsPacketCreatorForType( type : String ) : Boolean
		{
			var creator : IHydraPacketCreator;
			for each(creator in _creators)
				if( creator.packetType == type )
					return true;
			return false;
		}
		
		public function removePacketCreator( creator : IHydraPacketCreator ) : void
		{
			var i : int = 0;
			const l : int = _creators.length;
			for(;i<l;i++)
			{
				if( _creators[i] == creator )
				{
					_creators.splice(i, 1);
					break;
				}
			}
		}
		
		public function createPacket( type : String, timestamp : Number, userId : String, senderPeerId : String, info : Object ) : IHydraPacket
		{
			var creator : IHydraPacketCreator;
			for each(creator in _creators)
				if( creator.packetType == type )
					return creator.createPacket(type, timestamp, userId, senderPeerId, info);
			return null;
		}
	}
}
