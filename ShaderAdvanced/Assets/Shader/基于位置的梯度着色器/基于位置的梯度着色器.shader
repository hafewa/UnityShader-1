Shader "Custom/基于位置的梯度着色器" {
	Properties
	{
		_MainTex("MainTex",2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_fogColor("fogColor",Color) = (0.3, 0.4, 0.7, 1.0)
		_fogStart("fogStart",float) = 0.2
		_fogEnd("fogEnd",float) = 0.3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert finalcolor:mycolor vertex:myvert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input
		{
			float2 uv_MainTex;
			half fog;
		};

		fixed4 _Color;
		fixed4 _fogColor;
		float _fogStart;
		float _fogEnd;
		sampler2D _MainTex;

		void myvert(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input,data);

			float4 wPos = mul(unity_ObjectToWorld,v.vertex);

			//根据顶点坐标的y和自定义的_fogStart的距离除以_fogEnd-_fogStart的值算出此时颜色的插值
			//注意这里是转换到世界坐标空间的,所以inspector面板上postion的y就是这里的wPos.y,但是要明确的是inspector面板postion的y实际上是模型中心点的y坐标,例如本例中的cube,wPos.y是其中心点的坐标,它的最上面的坐标是wPos.y+0.5,最下面的坐标是wPos.y-0.5
			data.fog = saturate((wPos.y - _fogStart)/(_fogEnd-_fogStart));
		}

		void surf (Input IN, inout SurfaceOutput o)
		 {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
		}

		//自定义最终颜色输出函数,这个函数是surf执行完成之后再执行的,最终效果类似纪念谷碑的效果,需要将摄像机的背景颜色也调整为fogColor才行
		void mycolor(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			fixed3 fogColor = _fogColor.rgb;
 
			fixed3 tintColor = _Color.rgb;
 
			//根据插值计算出该像素点的颜色,形成梯度效果
			color.rgb = lerp(color.rgb * tintColor, fogColor, IN.fog);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
