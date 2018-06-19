Shader "Unlit/Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//高斯模糊后的贴图
		_BlurTex("Texture",2D) = "white" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform float4 _colorThreshold;
	uniform float4 _offsets;
	uniform float _bloomFact;
	uniform float4 _bloomColor;

	sampler2D _MainTex;
	sampler2D _BlurTex;

	float4 _MainTex_TexelSize;
	float4 _BlurTex_TexelSize;  

	//提亮部分的顶点数据结构
	struct v2f_highBright
	{
		float4 vertex : POSITION;
		float2 uv:TEXCOORD0;
	};

	//提亮部分的顶点函数
	v2f_highBright vert_highBright(appdata_img v)
	{
		v2f_highBright o;

		o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
		o.uv = v.texcoord;
		//dx中纹理从左上角为初始坐标，需要反向
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
		{
			o.uv.y = 1 - o.uv.y;
		}
		#endif
		return o;
	}

	//提亮部分的片段函数
	fixed4 frag_highBright(v2f_highBright v) : SV_Target
	{
		fixed4 col = tex2D(_MainTex,v.uv);

		//渲染中只有大于外部指定颜色_colorThreshold的才输出,否则就剔除
		return saturate(col - _colorThreshold);
	}

	//高斯模糊部分的顶点数据结构
	struct v2f_blur
	{
		float4 vertex : POSITION;
		float2 uv:TEXCOORD0;
		float4 uv01:TEXCOORD1;
		float4 uv23:TEXCOORD2;
		float4 uv45:TEXCOORD3;
	};

	//高斯模糊顶点函数,高斯模糊具体数学公式比较复杂,可以用下面的代码来模拟
	v2f_blur vert_blur(appdata_img v)
	{
		v2f_blur o;
		//根据Unity内置的_MainTex_TexelSizexy分量x(屏幕的1 / width)y分量(屏幕的1 / hight)来进行偏移,因为再C#脚本中offsets会被两次传入,且每次传入的时候xy分量不同,第一次传入x>0而y=0所以就在X方向上进行了偏移,然后同理再在Y方向上进行偏移
		_offsets *= _MainTex_TexelSize.xyxy;
		o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
		o.uv = v.texcoord.xy;
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
		{
			o.uv.y = 1 - o.uv.y;
		}
		#endif
		//为高斯模糊准备UV数据
		o.uv01 = o.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);  
        o.uv23 = o.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;  
        o.uv45 = o.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;  

		return o;
	}

	//高斯模糊片段函数,高斯模糊具体数学公式比较复杂,可以用下面的代码来模拟
	fixed4 frag_blur(v2f_blur v):SV_Target
	{
		fixed4 color = fixed4(0,0,0,0);  
        color += 0.40 * tex2D(_MainTex, v.uv);  
        color += 0.15 * tex2D(_MainTex, v.uv01.xy);  
        color += 0.15 * tex2D(_MainTex, v.uv01.zw);  
        color += 0.10 * tex2D(_MainTex, v.uv23.xy);  
        color += 0.10 * tex2D(_MainTex, v.uv23.zw);  
        color += 0.05 * tex2D(_MainTex, v.uv45.xy);  
        color += 0.05 * tex2D(_MainTex, v.uv45.zw); 

		return color;
	}

	//bloom(全局泛光,主要模拟HDR效果,比真实的HDR效果要差,但是性能要比HDR要好)部分
	//bloom顶点数据结构
	struct v2f_bloom
	{
		float4 vertex : POSITION;
		float2 uv:TEXCOORD0;
		float2 uv1:TEXCOORD1;
	};

	//bloom顶点函数
	v2f_bloom vert_bloom(appdata_img v)
	{
		v2f_bloom o;
		o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
		o.uv = v.texcoord;
		o.uv1 = v.texcoord;
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
		{
			o.uv.y = 1 - o.uv.y;
		}
		#endif

		return o;
	}

	//bloom片段函数,最终的效果
	fixed4 frag_bloom(v2f_bloom v):SV_Target
	{
		//主纹理采样,经过上边的步骤已经提亮和高斯模糊了
		fixed4 col_Main = tex2D(_MainTex,v.uv1);
		//然后再将上边经过提亮和高斯模糊的RT再次进行采样最终混合
		fixed4 col_blur = tex2D(_BlurTex,v.uv);
		
		//进行混合
		fixed4 finalCol =  col_Main + col_blur*_bloomFact*_bloomColor;
		return finalCol;
	}

	ENDCG

	SubShader
	{
		pass
		{
			ZTest Off  
            Cull Off  
            ZWrite Off  
            Fog{ Mode Off }  
  
            CGPROGRAM  
            #pragma vertex vert_highBright  
            #pragma fragment frag_highBright  
            ENDCG  
		}

		pass
		{
			ZTest Off  
            Cull Off  
            ZWrite Off  
            Fog{ Mode Off }  
  
            CGPROGRAM  
            #pragma vertex vert_blur  
            #pragma fragment frag_blur  
            ENDCG  
		}

		pass
		{
			ZTest Off  
            Cull Off  
            ZWrite Off  
            Fog{ Mode Off }  
  
            CGPROGRAM  
            #pragma vertex vert_bloom  
            #pragma fragment frag_bloom  
            ENDCG  
		}
	}
}
