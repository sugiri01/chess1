# 🚀 QUICK START - Multiplayer Chess

Get the app running in 5 minutes.

## Step 1: Start the Server (Terminal 1)

```bash
cd chess_app/server
npm install
npm start
```

You should see:
```
Chess server running on port 3000
```

## Step 2: Run Flutter App (Terminal 2)

```bash
cd chess_app
flutter pub get
flutter run
```

## Step 3: Test Multiplayer

### Option A: Use Two Devices/Emulators
1. Run app on Device 1
2. Run app on Device 2
3. Both tap same game mode (e.g., "RAPID")
4. Both tap "FIND MATCH"
5. They get matched together!

### Option B: Use Chrome + Mobile
1. Terminal 2: `flutter run -d chrome`
2. Terminal 3: `flutter run -d <your-device>`
3. Click "RAPID" on both
4. Click "FIND MATCH" on both
5. Play chess in real-time!

## 🎮 How to Play

1. **Home Screen**: Choose game mode (Bullet, Blitz, Rapid, etc.)
2. **Game Screen**: Tap "FIND MATCH" button
3. **Wait**: Server finds opponent (shows "Searching...")
4. **Match Found**: Board appears, you're assigned White or Black
5. **Play**: Drag pieces to make moves
6. **Win**: Checkmate, resign, or opponent timeout

## 🔧 Configuration

### Change Server URL (For Network Play)

Edit `lib/screens/chess_game_screen.dart` line 38:

```dart
// For local testing
_socketService.connect('http://localhost:3000');

// For network testing (replace with your IP)
_socketService.connect('http://192.168.1.100:3000');

// For production
_socketService.connect('https://your-server.com');
```

### Change Time Controls

Edit `server/server.js` line 35-37:

```javascript
this.clock = {
  whiteMs: 300000, // 5 minutes = 300000ms
  blackMs: 300000, // Change these values
  lastMoveTs: Date.now()
};
```

## ✅ Verify It's Working

### Server Health Check
Open browser: `http://localhost:3000/health`

Should show:
```json
{
  "status": "ok",
  "matches": 0,
  "players": 0,
  "queue": 0
}
```

### Check Server Logs
You should see:
```
Client connected: <socket-id>
Player <socket-id> joining queue
Match created: <match-id> - White: <player1>, Black: <player2>
```

### Check Flutter Console
You should see:
```
Connected to server
Match found: {matchId: ..., color: white}
Move result: {fen: ..., turn: black}
```

## 🐛 Common Issues

### "Not connected to server"
- Check server is running on port 3000
- Try `http://localhost:3000/health` in browser
- Check firewall isn't blocking port 3000

### "Connection refused"
- Make sure server started successfully
- Check for port conflicts (kill other apps on 3000)
- Try restarting server

### "Stuck on searching"
- Need TWO players to match
- Open app on second device/emulator
- Both must click same game mode

### Board not updating
- Check Flutter console for errors
- Verify Socket.IO connection in logs
- Restart both server and app

## 📱 Testing on Real Devices

### Same WiFi Network

1. Find your computer's IP address:
   - **Windows**: `ipconfig` → Look for IPv4
   - **Mac/Linux**: `ifconfig` → Look for inet

2. Example: `192.168.1.100`

3. Update Flutter code:
```dart
_socketService.connect('http://192.168.1.100:3000');
```

4. Build and install on devices:
```bash
flutter build apk
# Install APK on Android devices
```

5. Both devices connect to same WiFi

6. Open app on both devices

7. Select same game mode and find match!

## 🎯 What You Have

✅ Full multiplayer chess with real-time updates
✅ Server-authoritative game logic
✅ Clock management with timeouts
✅ Matchmaking system
✅ All UI screens (Home, Game, Profile, Missions, Refer)
✅ Same exact UI as the rummy app
✅ Ready for phase 2 development

## 📈 Next Steps

1. **Test the app** - Play some games!
2. **Read README.md** - Full documentation
3. **Explore code** - Understand architecture
4. **Plan phase 2** - Add database, auth, features
5. **Deploy** - Put on real server for production

---

**You're ready to play!** 🎉

Open two instances, find match, and enjoy real-time multiplayer chess.
