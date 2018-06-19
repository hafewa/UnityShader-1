Shader "Custom/Shader_SurFaceGroundAdd" {
	Properties {
		_Control ("Control", 2D) = "white" {}
		_Splat0("Splat0",2D) = ""{}
		_Splat1("Splat1",2D) = ""{}
		_Splat2("Splat2",2D) = ""{}
		_Splat3("Splat3",2D) = ""{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// 加上自定义的顶点程序vert
		// decal:add的意义就是blend one one,使用这个指令就可以使得第二张甚至更多张控制纹理起作用(当有很多Splat纹理时,大于4张)
		//finalcolor:Myfinalcolor使用自定义的finalcolor方法,finalcolor意思是最终输出颜色函数,可以在这个函数里做一些事情,比如雾化等
		#pragma surface surf Lambert decal:add vertex:vert finalcolor:Myfinalcolor fullforwardshadows

		//把target改为4.0也可以避免too many textures的报错,但是这样老一点的平台又不支持了(4.0以上的平台中TEXCOORD支持的就不止是到7了)
		//之所以报出too many textures的错,是因为我们最终编译后的shader中TEXCOORD的语义用到了TEXCOORD8,而target 3.0只支持TEXCOORD0-TEXCOORD7,所以才会报错
		//如果我们不进行雾化的计算,系统会自动给我们加上,因为没有自定义顶点程序和finalcolor函数对雾化的处理,编译器就会在顶点程序中使用 UNITY_FOG_COORDS(7)来存放雾化的数据(这宏定义就是简单的使用了一个语义为TEXCOORD7的fogCoord来存放)
		//因为雾化数据fogCoord使用了TEXCOORD7,下面系统还会在编译的时候给我们在顶点程序中自动加上关于lightmap的数据lmap,这个lmap使用的是TEXCOORD8,超过了TEXCOORD7,所以就报错了
		//所以我们需要加上顶点程序和finalcolor函数,并参照官方的做法来计算雾化,这样编译的时候系统就不会给我们在顶点程序中添加UNITY_FOG_COORDS(7),这样lmap就会使用到TEXCOORD7,所以就不会报错了(巨坑)
		#pragma target 3.0

		sampler2D _Control;
		float4 _Control_ST;
		sampler2D _Splat0;
		sampler2D _Splat1;
		sampler2D _Splat2;
		sampler2D _Splat3;

		struct Input 
		{
			//这里为什么不使用uv_开头,因为在下面的自定义顶点程序中这个关于控制纹理的uv坐标我们不通过宏来计算,而是自己手动计算,所以这里就不使用uv_开头
			float2 tc_Control;
			//剩下的各个纹理的uv坐标都是通过宏来计算,所以加上uv_开头,如果没有自定义的顶点程序,我们一般都要使用uv_开头来表示uv坐标,这样Unity才会在编译的时候使用默认的顶点程序中宏来为我们的uv来赋值
			float2 uv_Splat0;
			float2 uv_Splat1;
			float2 uv_Splat2;
			float2 uv_Splat3;
		};

		//顶点程序
		//此方法的实现参考TerrainSplatmapCommon中的SplatmapVert顶点方法
		void vert(inout appdata_full v, out Input data)
		{
			//这个宏就是将上边Input结构中的以uv_开头的纹理坐标赋值的过程
			UNITY_INITIALIZE_OUTPUT(Input,data);

			//手动将控制纹理的uv坐标就行赋值
			//使用TRANSFORM_TEX上边就要加上_Control_ST来进行偏移和缩放
			data.tc_Control = TRANSFORM_TEX(v.texcoord,_Control);

			//将顶点坐标转换到截平面的坐标系中,主要用来计算雾化
			float4 pos = UnityObjectToClipPos(v.vertex);

			//利用宏来给雾化的有关数据赋值
			//这里面会给Input结构体添加一个fogCoord,给下面的Myfinalcolor使用
			UNITY_TRANSFER_FOG(data,pos);
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 outc = fixed4(0,0,0,0);

			fixed4 c = tex2D (_Control, IN.tc_Control);
			outc+= c.r*tex2D(_Splat0,IN.uv_Splat0);
			outc+= c.g*tex2D(_Splat1,IN.uv_Splat1);
			outc+= c.b*tex2D(_Splat2,IN.uv_Splat2);
			outc+= c.a*tex2D(_Splat3,IN.uv_Splat3);

			o.Albedo = outc.rgb;

			//这样计算就可以将输出的alpha按照控制纹理中各个通道的值来确定,从而更加准确的计算alpha了
			o.Alpha = dot(c,float4(1,1,1,1));
		}

		//在最终颜色输出函数中加入雾化效果
		//此方法的实现参考TerrainSplatmapCommon中的SplatmapFinalColor方法
		void Myfinalcolor(Input IN,SurfaceOutput o,inout fixed4 col)
		{
			col *= o.Alpha;
			//这里是first pass使用的宏,具体参考Custom/Shader_SurFaceGroundFrist
			//UNITY_APPLY_FOG(IN.fogCoord,col);
			//这个是add pass使用的宏
			UNITY_APPLY_FOG_COLOR(IN.fogCoord,col,fixed4(0,0,0,0));
		}

		ENDCG
	}
	FallBack off
}
