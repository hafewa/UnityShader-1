Shader "Unlit/PixelCubeMap"
{
	Properties
	{
		_CubeMap ("CubeMap", cube) = "white" {}
		_MainColor("MainColor",color) = (1,1,1,1)
		_ReflectColor("ReflectColor",color) = (1,1,1,1)
		_HighLightColor("HighLightColo",color) = (1,1,1,1)
		_MainTex("MainTex",2D) = ""{}
		_Shinness("Shinness",range(1,64)) = 1
	}
	SubShader
	{
		//和平行光有光的光照shader这个一定要加,不然效果会很不正确
		tags{"LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			samplerCUBE _CubeMap;
			sampler2D _MainTex;
			float4 _MainColor;
			float4 _ReflectColor;
			float4 _HighLightColor;
			float _Shinness;

			struct v2f
			{
				float4 pos:POSITION;
				float3 uv:TEXCOORD0;
				float3 normal:TEXCOORD1;
				float2 texcoord:TEXCOORD2;
				float4 vertex:TEXCOORD3;
			};
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.texcoord = v.texcoord;

				o.normal = v.normal;

				o.vertex = v.vertex;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				float3 N = UnityObjectToWorldNormal(IN.normal);

				float3 V = normalize(WorldSpaceViewDir(IN.vertex));

				float3 L = normalize(WorldSpaceLightDir(IN.vertex));

				//视向量的反射向量,求视向量的反射向量比较好,因为这样我们当摄像机有位移时看到的表面就会变化
				//-V是因为我们这里需要的向量是眼睛指向物体顶点,而WorldSpaceViewDir(IN.vertex)计算出来的V是顶点指向眼睛的
				float3 uv = reflect(-V,N);
				//根据反射向量采样立方体贴图
				fixed4 texCube = texCUBE(_CubeMap,uv);

				fixed4 _Col = tex2D(_MainTex,IN.texcoord);

				_Col*= _MainColor;

				float NdotL = saturate(dot(N,L));

				//半角向量
				float3 H = normalize(L+V);

				//高光系数
				float HdotN = saturate(dot(N,H));

				//立方体反射和反射颜色混合
				texCube*= _ReflectColor;

				//漫反射作用于主纹理
				_Col*= _LightColor0 * NdotL;

				//高光反射作用于主纹理
				_Col+= _HighLightColor * pow(HdotN,_Shinness);

				//最终将立方体反射和主纹理叠加
				_Col += texCube ;

				return _Col;
			}
			ENDCG
		}
	}
}
