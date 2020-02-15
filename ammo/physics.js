
var Module = { TOTAL_MEMORY: 256*1024*1024 };

importScripts('ammo.js');
// H-A
// Y:Z
// Z:Y

Ammo().then( Ammo => {

	var interval;
	var bodies;
	const transform = new Ammo.btTransform();
	var buf; // = new Float32Array( bodies.length*7 );

	const collisionConfiguration = new Ammo.btDefaultCollisionConfiguration();
	const dispatcher = new Ammo.btCollisionDispatcher(collisionConfiguration);
	const overlappingPairCache = new Ammo.btDbvtBroadphase();
	const solver = new Ammo.btSequentialImpulseConstraintSolver();

	const dynamicsWorld = new Ammo.btDiscreteDynamicsWorld(dispatcher, overlappingPairCache, solver, collisionConfiguration);
	dynamicsWorld.setGravity(new Ammo.btVector3(0, -10, 0));

	const groundShape = new Ammo.btBoxShape(new Ammo.btVector3(50, 50, 50));
	const groundTransform = new Ammo.btTransform();
	groundTransform.setIdentity();
	groundTransform.setOrigin(new Ammo.btVector3(0, -50, 0));
	
	const floorBody = new Ammo.btRigidBody(
		new Ammo.btRigidBodyConstructionInfo(
			0,
			new Ammo.btDefaultMotionState(groundTransform),
			groundShape,
			new Ammo.btVector3(0, 0, 0)
		)
	);
	dynamicsWorld.addRigidBody(floorBody);

	function reset() {
		const side = Math.ceil( Math.pow( bodies.length, 1/3 ) );
		var i = 0;
		for (var x = 0; x < side; x++) {
			for (var y = 0; y < side; y++) {
				for (var z = 0; z < side; z++) {
					if(i == bodies.length) break;
					const body = bodies[i++];
					const origin = body.getWorldTransform().getOrigin();
					origin.setX( (x - side/2)*(2.2 + Math.random()));
					origin.setY( 10 + y * (3 + Math.random()));
					origin.setZ( 5 + (z - side/2)*(2.2 + Math.random()) - side - 3);
					const rotation = body.getWorldTransform().getRotation();
					rotation.setX(0);
					rotation.setY(0);
					rotation.setZ(0);
					rotation.setW(1);
				}
			}
		}
	}

	function simulate(dt) {
		dt = dt || 1;
		try {
			dynamicsWorld.stepSimulation(dt, 2);
		} catch(e) {
			console.log(e);
			clearInterval( interval );
			return;
		}
		var j = 0;
		for(var i=0; i < bodies.length; i++ ) {
			const body = bodies[i];
			body.getMotionState().getWorldTransform(transform);
			const origin = transform.getOrigin();
			buf[j+0] = origin.x();
			buf[j+1] = origin.z();
			buf[j+2] = origin.y();
			const rotation = transform.getRotation();
			buf[j+3] = -rotation.x();
			buf[j+5] = -rotation.y();
			buf[j+4] = -rotation.z();
			buf[j+6] = rotation.w();
			j += 7;
		}
		postMessage(buf);
	}

	onmessage = e => {
		//console.log(e);
		if( e.data.type == "update" ) {
			//console.log(e.data);
			simulate( e.data.delta, e.data.buf );
		} else if( e.data.type == "reset" ) {
			reset();
			simulate();
		} else if( e.data.type == "start" ) {
			console.log("start",e.data);
			if( bodies ) {
				for(var i = 0; i < bodies.length; i++) {
					dynamicsWorld.removeRigidBody(bodies[i]);
				}
			}
			bodies = [];
			const size = e.data.size/2;
			const boxShape = new Ammo.btBoxShape(new Ammo.btVector3( size, size, size ));
			for(var i = 0; i < e.data.boxes; i++) {
				const startTransform = new Ammo.btTransform();
				startTransform.setIdentity();
				const mass = 1;
				const localInertia = new Ammo.btVector3(0, 0, 0);
				boxShape.calculateLocalInertia(mass, localInertia);
				const body = new Ammo.btRigidBody(
					new Ammo.btRigidBodyConstructionInfo(
						mass,
						new Ammo.btDefaultMotionState(startTransform),
						boxShape,
						localInertia
					)
				);
				dynamicsWorld.addRigidBody(body);
				bodies.push(body);
			}

			buf = new Float32Array( bodies.length * 7 );
			reset();
			
			var last = Date.now();
			function loop() {
				const now = Date.now();
				simulate(now - last);
				last = now;
			}
			if( interval ) clearInterval( interval );
			interval = setInterval(loop, 1000/60 );
		}
	}
	postMessage("ready");
});
