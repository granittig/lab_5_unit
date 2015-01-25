package tests;

import game.network.ScoreServer;
import game.objects.Scene;
import game.graphics3d.Context;
import game.objects.Ball;

class Test {

	// основная функция старта приложения в языке Haxe
	public static function main() {
		trace("Running tests...");
		// поочередный запуск тестов
		ContextTest.test();
		BallTest.test();
		// тест с сервером асинхронный
		ScoreServerTest.test(function() {
			// подсчет результатов тестирования
			trace("Tests completed.");
			trace(""+done+" tests of "+(done+failed)+" passed, "+failed+" failed.");
		});
	}

	public static var done = 0; // успешно прошедшие тесты
	public static var failed = 0; // неудачные тесты

	public static function test(pass:Bool, message:String) {
		if(pass) done++;
		else {
			failed++;
			trace("Test failed: " + message);
		}
	}
}

// тестовые классы-обертки

class ScoreServerTest extends game.network.ScoreServer {
	public static function test(done) {

		flash.system.Security.allowDomain("*");
		flash.system.Security.loadPolicyFile("crossdomain.xml");

		// setHighScores

		ScoreServer.setHighScores([1,2,3]);

		// getHighScores

		ScoreServer.getHighScores(function(scores) {
			Test.test(scores[0] == 1, "scores[0]");
			Test.test(scores[1] == 2, "scores[1]");
			Test.test(scores[2] == 3, "scores[2]");
			done();
		});
	}
}

class ContextTest extends game.graphics3d.Context {
	public static function test() {
		var context = new ContextTest();

		// nextPowerOfTwo

		Test.test(Context.nextPowerOfTwo(111) == 128, "nextPowerOfTwo(111)");
		Test.test(Context.nextPowerOfTwo(222) == 256, "nextPowerOfTwo(222)");
		Test.test(Context.nextPowerOfTwo(8) == 8, "nextPowerOfTwo(8)");
		Test.test(Context.nextPowerOfTwo(17) == 32, "nextPowerOfTwo(17)");

		// rgbaToVec

		Test.test(context.rgbaToVec(0xFF00FF, 1.0)[3] == 1, "rgbaToVec(0xFF00FF, 1.0)[3]");
		Test.test(context.rgbaToVec(0xFF00FF, 0.0)[3] == 0, "rgbaToVec(0xFF00FF, 0.0)[3]");
		Test.test(context.rgbaToVec(0xFF00FF, 1.0)[0] == 1, "rgbaToVec(0xFF00FF, 1.0)[0]");
		Test.test(context.rgbaToVec(0xFF00FF, 1.0)[1] == 0, "rgbaToVec(0xFF00FF, 1.0)[1]");
	}

	function new() {
		// хак для создания инстанса класса, не создавая реального Stage3D контекста
		try {
			super(null, 0, 0);
		} catch(e:Dynamic) {}
	}
}

class BallTest extends game.objects.Ball {
	public static function test() {
		var paddle = new PaddleTest();
		var ball = new BallTest(paddle);

		// calcBallAngle

		ball.x = 0;
		paddle.x = 0;
		ball.y = 0;
		paddle.y = 0;

		paddle.x = 0;
		ball.calcBallAngle();
		Test.test(ball.ballXSpeed < 0, "calcBallAngle, arg 0");

		paddle.x = -25;
		ball.calcBallAngle();
		Test.test(ball.ballXSpeed > 0, "calcBallAngle, arg -25");

		paddle.x = 15;
		ball.calcBallAngle();
		Test.test(ball.ballXSpeed < 0, "calcBallAngle, arg 15");
	}

	function new(paddle:PaddleTest) {
		try {
			super(paddle, new game.data.Gameplay());
		} catch(e:Dynamic) {}
		removeEventListener(flash.events.Event.ENTER_FRAME, onFrame);
	}
}

class PaddleTest extends game.objects.Paddle {
	function new() {
		// хак для создания инстанса класса, не создавая реального объекта
		try {
			super();
		} catch(e:Dynamic) {}
		removeEventListener(flash.events.Event.ENTER_FRAME, onFrame);
	}
}