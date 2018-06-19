Shader "Custom/Shader_Ground"
{
	Properties
	{
		//_Control和_Splat0 - _Splat3 是shader中的全局纹理变量,shader会自动将其赋值,即是不在外部赋值也会有正确的结果,这个只适应于地形系统
		_Control ("Control", 2D) = "white" {}
		_Control_1 ("Control_1", 2D) = "white" {}
		_Splat0 ("_Splat0", 2D) = "white" {}
		_Splat1 ("_Splat1", 2D) = "white" {}
		_Splat2 ("_Splat2", 2D) = "white" {}
		_Splat3 ("_Splat3", 2D) = "white" {}
		_Splat4 ("_Splat4", 2D) = "white" {}
		_Splat5 ("_Splat5", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		//这个pass对于地形测采样使用的纹理贴图只针对全局的_Control和_Splat0 - _Splat3,剩下的要从第二张控制纹理中获取数据_Control_1,这个部分要使用第二个pass来完成
		//因为老的显卡可能不支持在一个pass中多次使用tex2D
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _Control;
			sampler2D _Splat0;
			float4 _Splat0_ST;
			sampler2D _Splat1;
			float4 _Splat1_ST;
			sampler2D _Splat2;
			float4 _Splat2_ST;
			sampler2D _Splat3;
			float4 _Splat3_ST;

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col = fixed4(0,0,0,0);

				fixed4 col_Ctrl = tex2D(_Control,IN.uv);

				//根据控制纹理当中的各个颜色通道值来确定各个其他纹理的采样
				//r是底图,也就是第一张地表纹理
				//gba是根据画刷按照顺序画出来的,画刷的颜料就是其他按照顺序的的贴图
				col += col_Ctrl.r*tex2D(_Splat0,IN.uv*_Splat0_ST.xy);
				col += col_Ctrl.g*tex2D(_Splat1,IN.uv*_Splat1_ST.xy);
				col += col_Ctrl.b*tex2D(_Splat2,IN.uv*_Splat2_ST.xy);
				col += col_Ctrl.a*tex2D(_Splat3,IN.uv*_Splat3_ST.xy);

				return col;
			}
			ENDCG
		}

		Pass
		{
			//直接将两个pass加起来
			blend one one
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			//由于以下的贴图不再是shader的全局变量,所以我们要在外部赋值
			sampler2D _Control_1;
			sampler2D _Splat4;
			float4 _Splat4_ST;
			sampler2D _Splat5;
			float4 _Splat5_ST;

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col = fixed4(0,0,0,0);

				fixed4 col_Ctrl = tex2D(_Control_1,IN.uv);

				//根据控制纹理当中的各个颜色通道值来确定各个其他纹理的采样
				//r是底图,也就是第一张地表纹理
				//gba是根据画刷按照顺序画出来的,画刷的颜料就是其他按照顺序的的贴图
				col += col_Ctrl.r*tex2D(_Splat4,IN.uv*_Splat4_ST.xy);
				col += col_Ctrl.g*tex2D(_Splat5,IN.uv*_Splat5_ST.xy);

				return col;
			}
			ENDCG
		}
	}
}
