Shader "Custom/CustomDiffuse" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// surface表示是表面着色器,surf表示片段函数命,Standard表示使用了Unity标准光照模型(和surf中的SurfaceOutputStandard参数对应,提供了各种光照数据)
		//#pragma surface surf Standard fullforwardshadows

		//使用了Lambert光照模型,surf的第二个参数需要改成SurfaceOutput,提供了一些基本漫反射的光照数据
		#pragma surface surf Lambert fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		//在标准着色器中这个Input不能为空,即使uv_MainTex不用
		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c =  _Color;
			o.Albedo = c.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
