﻿/* 
  * Copyright (C) 2009-2009 tcgcms.com <http://www.tcgcms.cn/> 
  *  
  *    本代码以公共的方式开发下载，任何个人和组织可以下载， 
  * 修改，进行第二次开发使用，但请保留作者版权信息。 
  *  
  *    任何个人或组织在使用本软件过程中造成的直接或间接损失， 
  * 需要自行承担后果与本软件开发者(三云鬼)无关。 
  *  
  *    本软件解决中小型商家产品网络化销售方案。 
  *     
  *    使用中的问题，咨询作者QQ邮箱 sanyungui@vip.qq.com 
  */

package
{
	import adobe.utils.CustomActions;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.external.ExternalInterface;
	import org.papervision3d.core.animation.channel.MatrixChannel3D;
	import org.papervision3d.core.math.Sphere3D;
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.parser.AParser;
	import flash.events.*;


	import flash.ui.*;
	import sandy.core.Scene3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.materials.attributes.*;
	import sandy.primitive.*;
	import sandy.util.*;
	import sandy.events.*;
  

	public class Main extends Sprite 
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var queue:LoaderQueue;
		private var numTree:Number = 50;
		
		private var earth:Sphere;
		private var moon:Sphere;
		
		private var imgxml:XML;
		private var sObj:Shape3D;
		private var myText:TextField = new TextField();
		private var totalFileSize:int;
		private var totalfilecount:int;
		private var logNUm:int;
		
		private var tGroupMove:Boolean = false;
		private var oldXyTGroup:Object = null;
		
		private var css:myCss  = new myCss();

		
		//文字显示
		private var logText:TextField = new TextField();
		private var copyright:TextField = new TextField();
		private var Contact:TextField = new TextField();
		
		public function Main():void
		{
			//设置影片居中
			stage.scaleMode = "noScale"; 
			stage.align = "LT";
			var loader:URLLoader=new URLLoader(new URLRequest("photos.xml"));
			loader.addEventListener(Event.COMPLETE, imgxmlcompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, xmlloadError); 
		}
		
		private function imgxmlcompleteHandler(e:Event):void{    
			imgxml=new XML(e.target.data);//此时，外部的xml数据被完全转存到内存myxml文件中  
			totalfilecount = imgxml.descendants("file").length();//得到图片总数,此处为3
			var i:int;//int效率快过Number
			if (totalfilecount <= 0) return;
			queue = new LoaderQueue();
			
			for (i = 0; i < totalfilecount; i++) {
				//@符号是读xml文件中带=号形式的属性的专用语法
				queue.add( imgxml.file[i].@id, new URLRequest(imgxml.file[i].@url) );	
				totalFileSize += parseInt(imgxml.file[i].@size);
			}
			
			myText.width = 300;
			myText.x = stage.stageWidth/2;
			myText.y = stage.stageHeight/2;
			myText.htmlText = "<p class='loading'>loading...</p>";
			myText.styleSheet = css;
			this.addChild(myText);
			logNUm = 1;
			
			logText.x = 20;
			logText.y = 20;

			
			logText.styleSheet =  css;
			logText.htmlText = "<p class='logo'>TaoYanXi.CN</p>";
			logText.width = 280;
			logText.height = 30;
			
			
			copyright.width = 330;
			copyright.height = 30;
			
			copyright.x = (stage.stageWidth -330)/2;
			copyright.y = stage.stageHeight - 60;
			copyright.styleSheet = css;
			
			copyright.htmlText = "<p class='copyright'>Copyright @ 2009 - 2009 TCG CMS system All Rights Reserved</p>";
			
			Contact.width = 230;
			Contact.height = 30;
			
			Contact.x = (stage.stageWidth -230)/2;
			Contact.y = stage.stageHeight - 35;
			Contact.styleSheet = css;
			
			Contact.htmlText = "<p class='copyright'>Email:sanyungui@vip.qq.com QQ:644139466</p>";
			
			
			this.addChild(Contact);
			this.addChild(copyright);
			this.addChild(logText);
			
			queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
			queue.addEventListener(QueueEvent.QUEUE_RESOURCE_LOADED, queueLoadResource);
			queue.start();
		}
		
		//函数功能：捕获Xml配置文件加载异常（主要是URL错误异常）
		private function xmlloadError(evt:IOErrorEvent):void {
			evt.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR,xmlloadError);
		}
		
		public function queueLoadResource(event:QueueEvent ):void 
		{
			myText.htmlText = "<p class='loading'>loading..." + parseInt( (logNUm / totalfilecount * 100).toString()) +"%</p>";
			logNUm++;
		}

		public function loadComplete(event:QueueEvent ):void
		{  
			
			camera = new Camera3D(stage.stageWidth, stage.stageHeight);
			camera.z = -800;
			var root:Group = createScene();
			scene = new Scene3D( "scene", this, camera, root );
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onmousedownHandler);
			//stage.addEventListener(MouseEvent.MOUSE_UP, onmouseupHandler);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onmousemoveHandler);
			
			myText.visible = false;
		}

		//鼠标按下左键
		private function onmousedownHandler(evEn:MouseEvent):void {
			this.tGroupMove = true;	//中心物体可以移动
			this.oldXyTGroup = null;
		}
		
		//鼠标左前释放
		private function onmouseupHandler(evEn:MouseEvent):void {
			this.tGroupMove = false;
		}
		
		private function onmousemoveHandler(evEn:MouseEvent):void {
			var myScene:Scene3D = this.scene;
			var group:Group = myScene.root;
			
			if (this.tGroupMove) {
				
				if (!this.oldXyTGroup)
				{
					this.oldXyTGroup = { x:stage.mouseX, y:stage.mouseY };
					
				}else{
					var m:TransformGroup = (group.getChildByName("SmllTeam") as TransformGroup);
					if (m)
					{
						var x:Number = Math.atan2(stage.mouseY - this.oldXyTGroup.y , stage.mouseX - this.oldXyTGroup.x);
						var y:Number = x * 180 / Math.PI;	
						m.rotateX += x;
						//m.rotateY += 90 - y; 
					}
					this.oldXyTGroup = { x:stage.mouseX, y:stage.mouseY };
				}
			}
		}
		
		// Create the scene graph based on the root Group of the scene
		private function createScene():Group
		{
			// Create the root Group
			var g:Group = new Group();
			
			var team:TransformGroup = new TransformGroup("SmllTeam");
			var i:int = 0;
	
			var materialAttr:MaterialAttributes = new MaterialAttributes(  
				new LineAttributes( 0, 0xD7D79D, 0 ), 
				new LightAttributes( true, 0.1) 
            ); 

            var material:Material = new ColorMaterial( 0xD7D79D, 1, materialAttr ); 
            material.lightingEnable = true; 
            var app:Appearance = new Appearance( material ); 
		
			var num:int = 60;    
            var anglePer:Number = ((Math.PI * 2) * 5 ) / num; 
			
			for each (var item:Object in queue.data)
			{
				var plane:Box = new Box(item.name, 40,30,1,"quad");	
				plane.addEventListener(MouseEvent.MOUSE_OVER, imgMouseOverHandler);
				plane.addEventListener(MouseEvent.MOUSE_OUT, imgMouseOutHandler);
				plane.addEventListener(MouseEvent.MOUSE_DOWN, imgMouseDownHandler);
				
				plane.enableBackFaceCulling = false;
				plane.enableEvents = true;
				var btm:BitmapMaterial = new BitmapMaterial(item.bitmapData);
				plane.appearance = app;
				
				plane.aPolygons[0].appearance = new Appearance(btm);
				plane.aPolygons[1].appearance = new Appearance(btm);	
				
				//plane.x = i * (20+1) -115;
				plane.y = - 165 + i*8;
				
				plane.x = Math.cos(i * anglePer ) *100;   
				plane.z = Math.sin(i * anglePer ) * 100;   
				//p.y = 120 * j;//改变y轴坐标 实现圆柱的效果  
				plane.rotateY = (i*anglePer) * (180/Math.PI) + 270;   	
				team.addChild(plane);
				
				i++;
			}
			
			
			g.addChild(team);
			return g;
		}
		
		private function imgMouseOverHandler(pEvt:Shape3DEvent):void
		{
			//if (sObj&&sObj.name!= pEvt.shape.name) sObj.rotateY = 0;
			//sObj = pEvt.shape;
		}
		
		private function imgMouseOutHandler(pEvt:Shape3DEvent):void
		{
			//if (sObj && sObj.name != pEvt.shape.name) pEvt.shape.rotateY = 0;
		}
		
		private function imgMouseDownHandler(pEvt:Shape3DEvent):void
		{
			//pEvt.shape.x += 12;
			
		}

		// The Event.ENTER_FRAME event handler tells the Scene3D to render
		private function enterFrameHandler( event : Event ) : void
		{
			var myScene:Scene3D = this.scene;
			var group:Group = myScene.root;
			
			var myMouseXOffset:Number = mouseX - stage.stageWidth / 2;
			var myMouseYOffset:Number = mouseY - stage.stageHeight / 2;
			
			
			camera.x = 200 * Math.cos(myMouseXOffset/200);
			camera.z = -800 * Math.sin(myMouseXOffset/200);
			camera.y = myMouseYOffset/2;
			camera.lookAt(0, 0, 0);
			
			
			
			var Bbox:TransformGroup = (group.getChildByName("SmllTeam") as TransformGroup);
			
			if (Bbox) 
			{
				Bbox.rotateY += 1;
			}
			
			
			/*
			for each (var item:Object in queue.data)
			{
				var plane:Box = (group.getChildByName(item.name) as Box);
				if( plane )
				{
					//plane.rotateY += 10;
				}
			}
			*/
	
			scene.render();
		}

		// This function handles the move foreward or backward simultaion
		private function keyPressedHandler(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case Keyboard.UP:
					camera.moveForward(5);
					break;
				case Keyboard.DOWN:
					camera.moveForward(-5);
					break;
			}
		}

		// This function handles the direction of the similation movement	
		private function mouseMovedHandler(event:MouseEvent):void {
			camera.pan=(event.stageX-300/2)/10;
			camera.tilt=(event.stageY-300/2)/20;   
		}	
	}
}