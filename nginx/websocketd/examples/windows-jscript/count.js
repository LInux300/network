// Copyright 2013 Joe Walnes and the websocketd team.
// All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Simple example script that counts to 10 at ~2Hz, then stops.
for (var i = 1; i <= 10; i++) {
  WScript.echo(i);
  WScript.sleep(500);
}
