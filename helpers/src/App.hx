
import h3d.scene.pbr.SpotLight;
import hxd.Res;
import h3d.Vector;
import h3d.scene.*;
import h3d.scene.fwd.*;
import h3d.helper.*;

class App extends hxd.App {

	var time = 0.0;
	var cube : Mesh;
	var pointLights = new Array<PointLight>();

	function new() {
		//h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
		super();
	}

	override function init() {

		s3d.camera.pos.set( 5, 5, 5 );
		s3d.camera.setFovX( 70, s3d.camera.screenRatio );
		
		new CameraController(s3d).loadFromCamera();

		new AxesHelper( s3d );
		new GridHelper( s3d, 10, 10 );

		var prim = new h3d.prim.Cube( 1, 1, 1, true );
		prim.unindex();
		prim.addNormals();
		prim.addUVs();

		cube = new Mesh( prim, s3d );
		cube.setPosition( 0, 0, 2 );
		cube.material.shadows = false;

		new AxesHelper( cube, 1 );
		new BoxHelper( cube, s3d );

	//	s3d.lightSystem.ambientLight.set( 0.3, 0.3, 0.3 );

	//	var dirLight = new DirLight( new Vector( 0.5, 0.5, -0.5 ), s3d );
	//	dirLight.enableSpecular = true;

		/*
		var spotLight = new SpotLight( s3d );
		spotLight.setPosition(-30,-30,30);
		spotLight.setDirection(new h3d.Vector(1,2,-5));
		spotLight.range = 70;
		spotLight.maxRange = 70;
		spotLight.angle = 70;
		spotLight.color.scale3(10);

		spotLight.shadows.mode = Static;
		s3d.computeStatic();
		spotLight.shadows.mode = Dynamic;
		
		var spotLightHelper = new SpotLightHelper( spotLight, s3d );
		*/
		
		var pointLightColors =  [0xEB304D,0x7FC309,0x288DF9];
		for( i in 0...pointLightColors.length ) {
			var l = new PointLight( s3d );
			l.enableSpecular = true;
			l.color.setColor( pointLightColors[i] );
			pointLights.push( l );
			new PointLightHelper( l );
		}

		/*
		var cache = new h3d.prim.ModelCache();
		var prim = cache.loadModel( Res.diamond6S );
		var diamond = prim.toMesh();
		diamond.setPosition( 3, 3, 3 );
		s3d.addChild( diamond );
		new BoxHelper( diamond, s3d );

		trace(diamond);
		*/
		
		//new VertexNormalsHelper( cast cube.primitive );
	}

	override function update( dt : Float ) {

		time += dt;

		cube.rotate( 0.01, 0.02, 0.03 );

		pointLights[0].x = Math.sin( time ) * 3;
		pointLights[1].y = Math.sin( time ) * 3;
		pointLights[2].z = Math.sin( time ) * 3;
	}

	static function main() {
		Res.initEmbed();
		new App();
	}
}
