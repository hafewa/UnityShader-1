Shader "Sbin/FusionColorAndCubeMapSurface" {
	Properties {
		_R("R",range(0,0.5)) = 0.2
		_Center("Center",range(-3.21,3.51)) = 0
		_MainColor("MainColor",Color) = (1,1,1,1)
		_TwoColor("TwoColor",Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cube("Cube",cube) = ""{}
	}
	SubShader 
	{
		tags{ "RenderType"="Opaque"}
		LOD 200
		
		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows vertex:vert 

		#pragma target 3.0

		sampler2D _MainTex;
		samplerCUBE _Cube;

		//surface不需要加语义
		struct Input 
		{
			float3 normal;
			float4 vertex;
			//如果没有顶点程序的话这个反射向量会自动赋值,但是名字一定是这这样的
			//float3 worldRefl;
			float z;
		};

		void vert(inout appdata_full v,out Input o)
		{
			o.normal = v.normal;
			o.vertex = v.vertex;

			o.z = v.vertex.z;
		}

		half _Glossiness;
		half _Metallic;
		float _Center;
		float4 _MainColor;
		float4 _TwoColor;
		float _R;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float3 N = UnityObjectToWorldNormal(IN.normal);
			float3 V = normalize(WorldSpaceViewDir(IN.vertex));

			//反射向量(拿视向量的反向量和法线进行求反射向量)
			float3 R = reflect(-V,N);

			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			//获得内建的反射向量采样Cube
			//fixed4 _cube = texCUBE(_Cube,IN.worldRefl);

			//因为我们这里需要从顶点程序中拿到z值,所以必须要有顶点程序,但是有了顶点程序worldRefl就不会被自动赋值了,所以上边我们从新计算了一个反射向量
			fixed4 _cube = texCUBE(_Cube,R);

			o.Albedo = _cube.rgb;

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = _cube.a;

			if(IN.z >= _Center)
			{
				//坐标点的Y到中心的距离
				float d = IN.z - _Center;

				//获得坐标点的Y到中心的距离占_R的比例
				float f = d/_R;

				//当IN.y > _Center + _R时f等于1,此时的f最终为0,颜色为纯_MainColor
				//当不是以上情况时就是在融合带的上半部分
				//*0.5是因为这里只是上半部分
				f = (1-saturate(f)) * 0.5;

				//*2是为了使得蓝色更蓝一点
				o.Albedo*=lerp(_MainColor,_TwoColor,f)*2;
			}
			else
			{
				//坐标点的Y到中心的距离
				float d = _Center - IN.z;

				//获得坐标点的Y到中心的距离占_R的比例
				float f = d/_R;

				//当IN.y < _Center - _R时f等于1,此时的f最终为0,颜色为纯_TwoColor
				//当不是以上情况时就是在融合带的下半部分
				f = (1-saturate(f)) * 0.5;

				o.Albedo*=lerp(_TwoColor,_MainColor,f)*2;
			}
		}
		ENDCG
	}
	FallBack "Diffuse"
}
