Shader "Custom/Shader_SurFaceGroundFrist" {
	Properties {
		_Control ("Control", 2D) = "white" {}
		_Splat0("Splat0",2D) = ""{}
		_Splat1("Splat1",2D) = ""{}
		_Splat2("Splat2",2D) = ""{}
		_Splat3("Splat3",2D) = ""{}
		_Strenth_G("Strenth_G",range(1,8)) = 4
		_Strenth_R("Strenth_R",range(1,8)) = 4
		_Strenth_White("Strenth_White",range(1,8)) = 4
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// 加上自定义的顶点程序vert
		//finalcolor:Myfinalcolor使用自定义的finalcolor方法,finalcolor意思是最终输出颜色函数,可以在这个函数里做一些事情,比如雾化等
		#pragma surface surf Lambert vertex:vert finalcolor:Myfinalcolor fullforwardshadows

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
		float _Strenth_G;
		float _Strenth_R;
		float _Strenth_White;

		struct Input 
		{
			//这里为什么不使用uv_开头,因为在下面的自定义顶点程序中这个关于控制纹理的uv坐标我们不通过宏来计算,而是自己手动计算,所以这里就不使用uv_开头
			float2 tc_Control;
			//剩下的各个纹理的uv坐标都是通过宏来计算,所以加上uv_开头,如果没有自定义的顶点程序,我们一般都要使用uv_开头来表示uv坐标,这样Unity才会在编译的时候使用默认的顶点程序中宏来为我们的uv来赋值
			float2 uv_Splat0;
			float2 uv_Splat1;
			float2 uv_Splat2;
			float2 uv_Splat3;
			float3 worldPos;
		};

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
		//finalcolor这个函数是最后的颜色处理流程,它是在已经计算了光照颜色之后再进行计算的,所以这里计算的颜色都是赋予了光照之后的
		//如果有需求使得下面的斑点和雪地的效果要在计算光照之前就进行计算,然后再计算光照,那么这部分代码应该移至surf中
		void Myfinalcolor(Input IN,SurfaceOutput o,inout fixed4 col)
		{
			col *= o.Alpha;

			//当最终颜色绿色通道大于红色通道的部分我们给它增加红色部分,使得它出现一个斑点效果(如秋天的落叶)
			col.rgb+= fixed3(0.8,0,0) *max(0,col.g - col.r)*_Strenth_G;

			//当输出颜色的红色通道部分大于某个定值(越小,得到的红色就越强)时我们给它增强红色效果
			col.rgb+= fixed3(0.8,0,0) *max(0,col.r - 0.35)*_Strenth_R;

			//我们想要一个雪地的效果,因为是雪地效果,加的应该就是白色,当输出颜色的绿色通道部分大于某个定值(越小,得到的雪地效果就越强)时我们给它增强白色效果
			//我们再想要一个当只有高于地平面一定的高度的时候才有雪的效果
			col.rgb+= fixed3(1,1,1) *max(0,col.g - 0.2)*_Strenth_White * max(0,IN.worldPos.y-1);

			UNITY_APPLY_FOG(IN.fogCoord,col);
		}

		//自定义兰伯特光照模型,前面一定要加Lighting,MyLambert替换上边Lambert即可,surf中的第二个参数要换成SurfaceOutput,SurfaceOutput是从surf传过来的,使用自定义的关注模型可以避免too many textures的报错,但是却不能使用系统自带的lambert光照模型了
		//5.0之后系统自带的Lambert光照模型中都含有GI光照,用这种方式来自定义地形的shader显然不能够发挥5.0之后光照系统的强大
		//lightDir是光的向量,atten是衰减,这些都是系统自动提供的
//		inline half4 LightingMyLambert(SurfaceOutput IN,float3 lightDir,float atten)
//		{
//			float NdotL = saturate(dot(IN.Normal,lightDir));
//
//			fixed4 c;
//
//			c.rgb = IN.Albedo.rgb * _LightColor0 * NdotL * atten;
//
//			c.a = IN.Alpha;
//
//			return c;
//		}
		ENDCG
	}

	//上面的shader是frist pass
	//这里就是使用第二个shader作为add pass,使用Dependency "AddPassShader" = 指定shader名即可
	//在Custom/Shader_SurFaceGroundAdd里有decal:add的指令,意思就是blend one one
	Dependency "AddPassShader" = "Custom/Shader_SurFaceGroundAdd"

	FallBack "Diffuse"
}
