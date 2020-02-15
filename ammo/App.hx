
import h3d.mat.Material;
import h3d.prim.Cube;
import h3d.Quat;
import h3d.scene.*;
import h3d.scene.fwd.*;
import hxd.Key;
import hxd.Res;
import js.Browser.window;
import js.html.Worker;

/*
	// H-A
	// Y:Z
	// Z:Y
*/
class App extends hxd.App {

	static inline var BUFSIZE = 7;

	var numBoxes = 500;
	var boxSize = 2;

	var boxes : Array<Mesh> = [];
	var boxPrim : Cube;
	var boxMaterial : Material;

	var physics : Worker;
	var text : h2d.Text;
	var textBackground : h2d.Graphics;

	override function init() {

		s3d.camera.pos.set( 25, 25, 25 );
		s3d.camera.setFovX( 70, s3d.camera.screenRatio );

		new AxesHelper( s3d );
		new GridHelper( s3d, 50, 50, 0x333333, 0x555555 );

		var tex = hxd.Res.checker_rough.toTexture();
		boxMaterial = h3d.mat.Material.create(tex);
		boxMaterial.shadows = true;
		boxMaterial.mainPass.enableLights = true;

		boxPrim = new h3d.prim.Cube( boxSize, boxSize, boxSize, true );
		boxPrim.unindex();
		boxPrim.addNormals();
		boxPrim.addUVs();

		new CameraController(s3d).loadFromCamera();

		physics = new Worker('physics.js');
		physics.onmessage = e -> {
			physics.onmessage = onPhysics;
			reset();
		};

		var font = hxd.res.DefaultFont.get();
		font.resizeTo( font.size );
		textBackground = new h2d.Graphics( s2d );
		textBackground.x = 10;
		textBackground.y = 10;
		text = new h2d.Text( font, textBackground );
		text.textColor = 0xffffff;
		text.x = 2;
		text.text = Std.string( boxes.length );
	}

	function reset() {
		if( boxes.length < numBoxes ) {
			for( i in 0...(numBoxes-boxes.length) )
				boxes.push( new Mesh( boxPrim, boxMaterial, s3d ) );
		} else if( boxes.length > numBoxes ) {
			var d = boxes.length-numBoxes;
			for( i in numBoxes...boxes.length )
				boxes[i].remove();
			boxes = boxes.slice(0,numBoxes);
		}
		physics.postMessage( { type: "start", boxes: numBoxes, size: boxSize } );
		text.text = Std.string( boxes.length );
	}
	
	override function update( dt : Float ) {
		if( Key.isPressed( Key.SPACE ) ) {
			physics.postMessage( { type: "reset" } );
		} else if( Key.isPressed( Key.UP ) ) {
			numBoxes += 100;
			reset();
		} else if( Key.isPressed( Key.DOWN ) ) {
			numBoxes -= 100;
			if( numBoxes < 0 ) numBoxes = 0;
			reset();
		}
	}

	function onPhysics(e) {
		var data : Dynamic = e.data;
		var j = 0;
		for( i in 0...boxes.length ) {
			var box = boxes[i];
			box.setPosition( data[j], data[j+1], data[j+2] );
			box.setRotationQuat( new Quat( data[j+3],  data[j+4], data[j+5], data[j+6]) );
			j += BUFSIZE;
		}
	}

	static function main() {
		h3d.mat.MaterialSetup.current = new h3d.mat.PbrMaterialSetup();
		Res.initEmbed();
		new App();
	}
}

class AxesHelper extends h3d.scene.Graphics {

	public function new( ?parent : h3d.scene.Object, size = 2.0, colorX = 0xEB304D, colorY = 0x7FC309, colorZ = 0x288DF9, lineWidth = 2.0 ) {

		super( parent );

		material.props = h3d.mat.MaterialSetup.current.getDefaults( "ui" );

		lineShader.width = lineWidth;

		setColor( colorX );
		lineTo( size, 0, 0 );

		setColor( colorY );
		moveTo( 0, 0, 0 );
		lineTo( 0, size, 0 );

		setColor( colorZ );
		moveTo( 0, 0, 0 );
		lineTo( 0, 0, size );
	}
}

class GridHelper extends h3d.scene.Graphics {

	public function new( ?parent : Object, size = 10.0, divisions = 10, color1 = 0x444444, color2 = 0x888888, lineWidth = 1.0 ) {

		super( parent );

		material.props = h3d.mat.MaterialSetup.current.getDefaults( "ui" );

		lineShader.width = lineWidth;

		var hsize = size / 2;
		var csize = size / divisions;
		var center = divisions / 2;
		for( i in 0...divisions+1 ) {
			var p = i * csize;
			setColor( ( i!=0 && i!=divisions && i%center==0 ) ? color2 : color1 );
			moveTo( -hsize + p, -hsize, 0 );
			lineTo( -hsize + p, -hsize + size, 0 );
			moveTo( -hsize, -hsize + p, 0 );
			lineTo( -hsize + size, -hsize + p, 0 );
		}
	}
}
