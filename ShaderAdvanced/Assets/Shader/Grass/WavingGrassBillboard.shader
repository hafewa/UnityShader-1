// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//这个shader就是Unity内建的关于草的Shader,这个在Unity引擎中本来就有,所以如果我们的项目中没有这个shader,它也会正常运行.
//但是我们将这个Shader从Unity官网下载下来后放到我们的项目中,那么Unity就会使用这个shader了,所以我们可以修改这个shader来改变草的一些效果,注意shader名一个字都不能变
//不过这个shader直接放进项目后并不能直接起作用,我们需要在Terrain面板属性的第六项草的面板中点击Refresh按钮才行
Shader "Hidden/TerrainEngine/Details/BillboardWavingDoublePass" {
	Properties {
		_WavingTint ("Fade Color", Color) = (.7,.6,.5, 0)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_WaveAndDistance ("Wave and distance", Vector) = (12, 3.6, 1, 1)
		_Cutoff ("Cutoff", float) = 0.5
	}
	
CGINCLUDE
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

struct v2f {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float4 uv : TEXCOORD0;
	UNITY_VERTEX_OUTPUT_STEREO
};
v2f BillboardVert (appdata_full v) {
	v2f o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	WavingGrassBillboardVert (v);
	o.color = v.color;
	
	o.color.rgb *= ShadeVertexLights (v.vertex, v.normal);
		
	o.pos = UnityObjectToClipPos(v.vertex);	
	o.uv = v.texcoord;
	return o;
}
ENDCG

	SubShader {
		Tags {
			"Queue" = "Geometry+200"
			"IgnoreProjector"="True"
			"RenderType"="GrassBillboard"
			"DisableBatching"="True"
		}
		Cull Off
		LOD 200
		ColorMask RGB
				
CGPROGRAM
#pragma surface surf Lambert vertex:MyWavingGrassBillboardVert addshadow exclude_path:deferred
			
sampler2D _MainTex;
fixed _Cutoff;
float4 _GrassPointPos;

struct Input {
	float2 uv_MainTex;
	fixed4 color : COLOR;
};


//该顶点程序在TerrainEngine.cginc中已经存在,这里只是简单拷贝过来,只是在前面加了个My,不然会报重复的错误
fixed4 MyTerrainWaveGrass (inout float4 vertex, float waveAmount, fixed4 color)
{
	//将顶点转换到世界空间
	float4 worldPos = mul(unity_ObjectToWorld,vertex);

	//求得离中心位置的距离
	float dis = distance(worldPos.xyz,float3(_GrassPointPos.x,_GrassPointPos.y,_GrassPointPos.z));

	float scale = 1.0;
	if(dis < 5)
		scale = 4.0;

	//从这里可以看出这几个变量即是草动起来的关键所在,在x和z轴方向上来回摆动
	float4 _waveXSize = float4(0.012, 0.02, 0.06, 0.024) * _WaveAndDistance.y*scale;
	float4 _waveZSize = float4 (0.006, .02, 0.02, 0.05) * _WaveAndDistance.y*scale;
	float4 waveSpeed = float4 (0.3, .5, .4, 1.2) * 4*scale;


	float4 _waveXmove = float4(0.012, 0.02, -0.06, 0.048) * 2*scale;
	float4 _waveZmove = float4 (0.006, .02, -0.02, 0.1)*scale;

	float4 waves;
	waves = vertex.x * _waveXSize;
	waves += vertex.z * _waveZSize;

	// Add in time to model them over time
	waves += _WaveAndDistance.x * waveSpeed;

	float4 s, c;
	waves = frac (waves);
	FastSinCos (waves, s,c);

	s = s * s;
	
	s = s * s;

	float lighting = dot (s, normalize (float4 (1,1,.4,.2))) * .7;

	s = s * waveAmount;

	float3 waveMove = float3 (0,0,0);
	waveMove.x = dot (s, _waveXmove);
	waveMove.z = dot (s, _waveZmove);

	vertex.xz -= waveMove.xz * _WaveAndDistance.z;
	
	// apply color animation
	
	// fix for dx11/etc warning
	fixed3 waveColor = lerp (fixed3(0.5,0.5,0.5), _WavingTint.rgb, fixed3(lighting,lighting,lighting));
	
	// Fade the grass out before detail distance.
	// Saturate because Radeon HD drivers on OS X 10.4.10 don't saturate vertex colors properly.
	float3 offset = vertex.xyz - _CameraPosition.xyz;
	color.a = saturate (2 * (_WaveAndDistance.w - dot (offset, offset)) * _CameraPosition.w);
	
	return fixed4(2 * waveColor * color.rgb, color.a);
}

//广告版(始终面向摄像机)的算法也是在TerrainEngine.cginc,这里直接拿过了改了下名字
void MyTerrainBillboardGrass( inout float4 pos, float2 offset )
{
	float3 grasspos = pos.xyz - _CameraPosition.xyz;
	if (dot(grasspos, grasspos) > _WaveAndDistance.w)
		offset = 0.0;
	pos.xyz += offset.x * _CameraRight.xyz;
	pos.xyz += offset.y * _CameraUp.xyz;
}

void MyWavingGrassBillboardVert (inout appdata_full v)
{
	MyTerrainBillboardGrass (v.vertex, v.tangent.xy);
	// wave amount defined by the grass height
	float waveAmount = v.tangent.y;
	v.color = MyTerrainWaveGrass (v.vertex, waveAmount, v.color);
}

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
	o.Albedo = c.rgb;
	o.Alpha = c.a;
	clip (o.Alpha - _Cutoff);
	o.Alpha *= IN.color.a;
}

ENDCG			
	}

	Fallback Off
}
