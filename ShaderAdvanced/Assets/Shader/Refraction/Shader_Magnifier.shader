Shader "Unlit/Shader_Magnifier"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Offset("Offset",range(-2,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		GrabPass{}

		Pass
		{
			blend one zero
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 N:Normal;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 proj:TEXCOORD1;
				float2 offset_uv:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _GrabTexture;
			float4 _MainTex_ST;
			float _Offset;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.proj = ComputeGrabScreenPos(o.vertex);

				//将原始法线变换到视空间,并且法线和视空间X方向的夹角
				//视空间的变换矩阵为UNITY_MATRIX_MV,要想将法线变换到视空间,就要使得法线和UNITY_MATRIX_MV(一个4X4的矩阵)的逆转矩阵相乘即可(和将法线变换到世界空间类似)
				//UNITY_MATRIX_MV的逆转矩阵为UNITY_MATRIX_IT_MV(Unity已经提供给我们了)
				//因为我们需要得到法线和视空间X方向的夹角,所以我们只需要从UNITY_MATRIX_IT_MV取得其X方向上的分量再进行dot即可
				o.offset_uv.x = -dot(v.N,UNITY_MATRIX_IT_MV[0].xyz);//为什么取负,根据放大镜的图解(图在项目中),当法线和视空间X方向的夹角大于90度时为dot为负,但是我们这个时候的采样要在原基础上右移一点
				//同理我们得到法线和视空间Y方向的夹角,而在y轴上就不需要取反了
				o.offset_uv.y = dot(v.N,UNITY_MATRIX_IT_MV[1].xyz)*(1600/600);//1600/600是当前屏幕分辨率的宽高比,如果不乘上这个宽高比,看到的画面是x方向上被拉伸的多,y方向上拉伸的少,整体看起来就被拉长了

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 col = tex2D(_MainTex, i.uv);

				i.proj.xy+=i.offset_uv*_Offset;

				fixed4 Magnifier_col = tex2Dproj(_GrabTexture,i.proj);

				return Magnifier_col;
			}
			ENDCG
		}
	}
}
