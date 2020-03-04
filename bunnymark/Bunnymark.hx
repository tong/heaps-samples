
import hxd.Key;
import hxd.Res;
import h2d.SpriteBatch;

class Bunny extends BatchElement {

	var vx : Float;
	var vy : Float;
	var gravity = 0.5;
	var width : Int;
	var height : Int;

	public function new( tile : h2d.Tile, vx : Float, vy : Float ) {
		super( tile );
		this.vx = vx;
		this.vy = vy;
		width = Std.int( tile.width );
		height = Std.int( tile.height );
	}

	public override function update( dt : Float ) {
		x += vx;
		y += vy;
		vy += gravity;
		if( x < Bunnymark.minX ) {
			x = Bunnymark.minX;
			vx *= -1;
		} else if( (x + width) > Bunnymark.maxX ) {
			x = Bunnymark.maxX - width;
			vx *= -1;
		}
		if( y < Bunnymark.minY ) {
			y = Bunnymark.minY;
			vy = 0;
		} else if( (y + height) > Bunnymark.maxY ) {
			y = Bunnymark.maxY - height;
			vy *= -0.85;
			if( Math.random() > 0.5 ) vy -= Math.random() * 6;
		}
		return true;
	}
}

class Bunnymark extends hxd.App {

	public static var minX(default,null) = 0;
	public static var minY(default,null) = 0;
	public static var maxX(default,null) = 600;
	public static var maxY(default,null) = 600;

	var tile : h2d.Tile;
	var bunnies : h2d.SpriteBatch;
	var count = 0;
	var amount = 100;
	var text : h2d.Text;
	var textBackground : h2d.Graphics;

	override function init() {

		var names = ["1","2","3","4","5","ash","batman","bb8","frankenstein","neo","sonic","spidey","stormtrooper","superman","tron","v3","wolverine"];
		tile = Res.load( 'bunny_'+names[Std.int(Math.random()*names.length)]+".png" ).toTile();

		bunnies = new SpriteBatch( tile, s2d );

		var font = hxd.res.DefaultFont.get();
		font.resizeTo( font.size * 2 );
		textBackground = new h2d.Graphics( s2d );
		textBackground.x = 10;
		textBackground.y = 10;
		text = new h2d.Text( font, textBackground );
		text.textColor = 0x000000;
		text.x = 2;

		onResize();

		addBunnies();
	}

	function addBunnies() {
		for( i in 0...amount ) {
			var bunny = new Bunny( tile, Math.random()*10-5, Math.random()*5-3 );
			bunny.x = s2d.mouseX;
			bunny.y = s2d.mouseY;
			bunnies.add( bunny );
		}
		count += amount;
		updateInfoText();
	}

	function removeBunnies() {
		var i = 0;
		for( bunny in bunnies.getElements() ) {
			bunny.remove();
			count--;
			if( ++i >= amount ) break;
		}
		updateInfoText();
	}

	override function update(dt:Float) {
		if( Key.isDown( Key.DOWN ) || Key.isDown( Key.MOUSE_LEFT ) )
			addBunnies();
		if( Key.isDown( Key.UP ) || Key.isDown( Key.MOUSE_RIGHT ) )
			removeBunnies();
		if( Key.isDown( Key.MOUSE_MIDDLE ) ) {
			bunnies.clear();
			count = 0;
			updateInfoText();
		}
		for( c in bunnies.getElements() ) cast(c,Bunny).update( dt );
	}

	function updateInfoText( ) {
		text.text = Std.string( count );
		textBackground.clear();
		textBackground.beginFill( 0xFFFFFF, 0.75 );
		textBackground.drawRect( 0, 0, text.textWidth+5, text.textHeight );
		textBackground.endFill();
	}

	override function onResize() {
		var win = hxd.Window.getInstance();
		maxX = win.width;
		maxY = win.height;
	}

	static function main() {
		Res.initEmbed();
		new Bunnymark();
	}
}
