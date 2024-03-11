import { Room, Client } from "colyseus";
import { MyRoomState, OtherPlayer } from "./schema/MyRoomState";
import * as fs from 'fs';
export class MyRoom extends Room<MyRoomState> {

  
  onCreate (options: any) {
    this.setState(new MyRoomState());
    this.setMetadata({ plot: options["h"]["id"] });
    console.log(options["h"]["id"]);
    
    
    this.onMessage("proximitychat", (client, x) => {
      const player2 = this.state.players.get(client.sessionId);
      this.broadcast("voiceChat", {muted: player2.muted, channel: player2.curchannel, input: x.toString(), sessionId: client.sessionId});
    });

    this.setSimulationInterval((deltaTime) => {
      if (fs.existsSync("public/" +  this.metadata.plot)) {
      var locations = fs.readFileSync("public/" + this.metadata.plot).toString();
      var players = locations.split(":")[1].split(";");
      players.forEach((v, i) => {
        var val = v.split(",");
        this.state.players.forEach((op, k) => {
          if (op.mc == val[0]) {
            op.x = Math.round(parseFloat(val[1]));
            op.y = Math.round(parseFloat(val[2]));
            op.z = Math.round(parseFloat(val[3]));
            op.angle = Math.round(parseFloat(val[4]));
            op.standingOn = val[5];
            op.curchannel = Math.round(parseFloat(val[6]));
            op.muted = Math.round(parseFloat(val[7]));
          }
        });
      });
    }
    })

  }

  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new OtherPlayer();
    this.state.players.set(client.sessionId, player);
    player.x = 0;
    player.y = 0;
    player.mc = options["h"]["mc"];
    player.z = 0;
    player.curchannel = 0;
    player.muted = 0;
    player.key = client.sessionId;
    player.standingOn = "err";
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
