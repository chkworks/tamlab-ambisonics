// Check for devices
ServerOptions.devices;


// Setting the server options
(
o = Server.default.options;
o.outDevice = "Interface";
o.numOutputBusChannels = 30;
o.sampleRate = 48000;
o.memSize = 2.pow(20);
o.numWireBufs = 128;
)


// First Order Ambisonic code for just the first row of speakers (output 1 - 12)
(
SynthDef.new(\foatest, {
	arg out = 0, freq = 440, amp = 0.1;
	var sig;

	sig = SinOsc.ar(freq);
	sig = sig * amp;

	// encoding
	~encoder = FoaEncoderMatrix.newOmni
	sig = FoaEncode.ar(sig, ~encoder);

	// transformation
	sig = FoaPush.ar(
		sig,
		MouseX.kr(0, pi/2).poll,
		LFSaw.kr(0.5).range(-pi, pi),
		MouseY.kr(0, 1)
	);

	// decoding
	~decoder = FoaDecoderMatrix.newPanto(12, 'flat', 'dual');
	sig = FoaDecode.ar(sig, ~decoder);

	Out.ar(out, sig);
}).add;
)

Synth(\foatest);



// Higher Order Ambisonic example for all speakers

(
SynthDef.new(\hoatest, {
	arg out = 0, freq = 440, amp = 0.1;
	var sig;

	// Setting variables for the HOA encoder and decoder
	var theta = 0.0;
	var phi = 0.0;
	var radius = 1.5;
	var order = 3;

	sig = SinOsc.ar(freq);
	sig = sig * amp;

	// Encode
	sig = HoaEncodeDirection.ar(sig, theta, phi, radius, order);

	// Transform
	sig = HoaRTT.ar(
		sig,
		MouseX.kr(0, 2pi),
		0,
		MouseY.kr(0, pi),
		order
	);

	// Speaker positions
	~directions = [
		[ 15, 0 ], [ 45, 0 ], [ 75, 0 ], [ 105, 0 ], [ 135, 0 ], [ 165, 0 ],
		[ 195, 0 ], [ 225, 0 ], [ 255, 0 ], [ 285, 0 ], [ 315, 0 ], [ 345, 0 ],
		[ 30, 33 ], [ 90, 33 ], [ 150, 33 ], [ 210, 33 ], [ 270, 33 ], [ 330, 33 ],
		[ 45, 52 ], [ 135, 52 ], [ 225, 52 ],[ 315, 52 ],
		[ 0, 90 ]
	].degrad;

	// Decode
	~decoder = HoaMatrixDecoder.newProjection(~directions, 'basic', 'amp', order);
	sig = HoaDecodeMatrix.ar(sig, ~decoder);

	Out.ar(out, sig);
}).add;
)

Synth(\hoatest);