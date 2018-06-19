Shader "Unlit/DiffuseLightFrag"
{
	//将Lambert光照模型在片段程序中实现,优点是画面更加细腻,因为像素计算中要比顶点多很多
	SubShader
	{

		Pass
		{
			tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "lighting.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float4 vertex:TEXCOORD0;
				float3 normal:TEXCOORD1;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;

				//片段程序处理光照的话求法线和光向量就不能放在顶点程序中,也要挪动到片段程序中
				//原因是顶点程序和片段程序的计算频率是差很多的,片段程序会比顶点程序计算多很多,但是这样表现更好,但是更耗性能
				//获得法向量
				//o.normal = UnityObjectToWorldNormal(v.normal);

				//获得光向量
				//o.lightDir = normalize(WorldSpaceLightDir(v.vertex));

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.normal = v.normal;
				o.vertex = v.vertex;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//环境光
				fixed4 col = UNITY_LIGHTMODEL_AMBIENT;

				//获得法向量
				float3 N = UnityObjectToWorldNormal(IN.normal);

				//获得光向量
				float3 L = normalize(WorldSpaceLightDir(IN.vertex));

				//漫反射系数
				float DiffuseValue = saturate( dot(N,L));

				//漫反射
				col += _LightColor0 * DiffuseValue;

				return col;
			}
			ENDCG
		}
	}
}
