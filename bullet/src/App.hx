
import bullet.Bt.DefaultCollisionConfiguration;
import bullet.Bt.DiscreteDynamicsWorld;
import bullet.Bt.RigidBody;
import h3d.helper.AxesHelper;
import h3d.helper.GridHelper;
import h3d.mat.Material;
import h3d.prim.Cube;
import h3d.Quat;
import h3d.scene.*;
import hxd.Key;
import hxd.Res;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.Worker;

private class Box {

	public var mesh : Mesh;
	public var body : RigidBody;

	public function new( size : Float, mass : Float, parent : Object, world : DiscreteDynamicsWorld ) {
		
		var prim = new h3d.prim.Cube( size, size, size, true );
		prim.unindex();
		prim.addNormals();
		prim.addUVs();
		
		var tex = hxd.Res.checker_rough.toTexture();
		var material = h3d.mat.Material.create(tex);

		mesh = new Mesh( prim, material, parent );

		var size = size/2;
		var boxShape = new bullet.Bt.BoxShape(new bullet.Bt.Vector3( size, size, size ));
		var startTransform = new bullet.Bt.Transform();
		startTransform.setIdentity();
		var localInertia = new bullet.Bt.Vector3(0, 0, 0);
		boxShape.calculateLocalInertia( mass, localInertia );
		body = new bullet.Bt.RigidBody(
			new bullet.Bt.RigidBodyConstructionInfo(
				mass,
				new bullet.Bt.DefaultMotionState(startTransform,new bullet.Bt.Transform()),
				boxShape,
				localInertia
			)
		);
		world.addRigidBody( body );
	}

	public function update( dt : Float ) {
		var origin = body.getWorldTransform().getOrigin();
		mesh.setPosition( origin.x(), origin.z(), origin.y() );
		var rotation = body.getWorldTransform().getRotation();
		mesh.setRotationQuat( new Quat( -rotation.x(), -rotation.z(), -rotation.y(), rotation.w() ) );
	}
}

/*
	// H-A
	// Y:Z
	// Z:Y
*/
class App extends hxd.App {

	var world : DiscreteDynamicsWorld;
	var boxes : Array<Box> = [];

	override function init() {

		s3d.camera.pos.set( 15, 15, 15 );
		s3d.camera.setFovX( 70, s3d.camera.screenRatio );

		new AxesHelper( s3d );
		new GridHelper( s3d, 50, 50, 0x333333, 0x555555 );

		new CameraController(s3d).loadFromCamera();

		var collisionConfiguration = new bullet.Bt.DefaultCollisionConfiguration();
		var dispatcher = new bullet.Bt.CollisionDispatcher(collisionConfiguration);
		var broadphase = new bullet.Bt.DbvtBroadphase();
		var solver = new bullet.Bt.SequentialImpulseConstraintSolver();
		world = new bullet.Bt.DiscreteDynamicsWorld(dispatcher, broadphase, solver, collisionConfiguration);
		world.setGravity(new bullet.Bt.Vector3(0,-10,0));
		
		var groundShape = new bullet.Bt.StaticPlaneShape(new bullet.Bt.Vector3(0, 1, 0), 1);
		var groundTransform = new bullet.Bt.Transform();
		groundTransform.setIdentity();
		groundTransform.setOrigin(new bullet.Bt.Vector3(0, -1, 0));
		var centerOfMassOffsetTransform = new bullet.Bt.Transform();
		centerOfMassOffsetTransform.setIdentity();
		var floorBody = new bullet.Bt.RigidBody(
			new bullet.Bt.RigidBodyConstructionInfo(
				0,
				new bullet.Bt.DefaultMotionState(groundTransform,centerOfMassOffsetTransform),
				groundShape,
				new bullet.Bt.Vector3(0, 0, 0)
			)
		);
		world.addRigidBody(floorBody);
				
		var box = new Box( 1, 1, s3d, world );
		box.body.getWorldTransform().getOrigin().setY(5);
		boxes.push( box );
		
		var box2 = new Box( 4, 3, s3d, world );
		var origin = box2.body.getWorldTransform().getOrigin();
		origin.setY(10);
		origin.setX(2);
		boxes.push( box2 );
	}
	
	override function update( dt : Float ) {
		world.stepSimulation( dt, 2 );
		for( box in boxes ) {
			box.update( dt );
		}
	}
	static function main() {
		window.onload = function() {
			Res.initEmbed();
			new App();
		}
	}
}
