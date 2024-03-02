import { Room, Client } from "colyseus";
import { MyRoomState, OtherPlayer } from "./schema/MyRoomState";

export class MyRoom extends Room<MyRoomState> {


  
  onCreate (options: any) {
    //this.roomId = options["h"]["id"];
    this.setState(new MyRoomState());
    
    
    this.onMessage("proximitychat", (client, x) => {
      const player2 = this.state.players.get(client.sessionId);
      this.state.players.forEach((op, cl) => {
        if (player2.x - 32 < op.x) {
          if (player2.y + 32 > op.y) {
            if (player2.z + 32 > op.z) {
              if (x.vol > 0.015) {
                this.clients.find(client => client.sessionId == cl).send("voiceChat", {x: player2.x, y: player2.y, z: player2.z, input: x.aud, sessionId: client.sessionId});
              }
            }
          }
        }
      });
    });

  }

  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new OtherPlayer();
    this.state.players.set(client.sessionId, player);
    player.x = 0;
    player.y = 0;
    player.z = 0;
    player.key = client.sessionId;
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
