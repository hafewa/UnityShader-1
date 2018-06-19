Shader "QQ/VP/Illumination_Bump"
{
	Properties
	{
		_Color("Color",Color) = (0.5,0.5,0.5,1)
		_MainTex("Texture", 2D) = "white" {}
		[NoScaleOffset]_BumpTex("Bump",2D) = "white" {}
		_Illum("Illumination",Color) = (1,1,0,1)
		_ProjectionColor("ProjectionColor",Color) = (0,0,0,.75)
		_ProjectionLength("ProjectionLength",Range(0,100)) = 10
		_ProjectionFadeout("Fadeout distance",float) = 5
	}
		SubShader
		{
			CGINCLUDE
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"  
			ENDCG
			Tags{ "RenderType" = "Transparent"
			"Queue" = "Transparent" }
			LOD 100

			//这个Pass用来渲染平行光的漫反射和表面法线凹凸效果,但是本例子没有平行光,所以这个pass只是渲染了_Illum和环境光
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM
				#pragma multi_compile_fwdbase_fullshadows
				#define projection_illm
				#define projection_bump
				#include "LightModel.cginc"
				ENDCG
			}

			//这个Pass用来渲染投影,但是本例没有平行光,所以其实这个pass没有什么作用,但是一旦加一个平行光就会产生两个投影
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				ZWrite Off
				Cull Off
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#include "Porjection.cginc"
				ENDCG
			}

			//这个Pass用来渲染点光源的漫反射和表面法线凹凸效果外加环境光和_Illum
			Pass
			{
				Blend One One
				Tags{ "LightMode" = "ForwardAdd" }
				CGPROGRAM
				#pragma multi_compile_fwdadd_fullshadows
				#define projection_illm
				#define projection_bump
				#include "LightModel.cginc"
				ENDCG
			}

			//点光源的投影
			Pass
			{
				Tags{ "LightMode" = "ForwardAdd" }
				ZWrite Off
				Cull Off
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#include "Porjection.cginc"
				ENDCG
			}
		}
		FallBack "Diffuse"
}
