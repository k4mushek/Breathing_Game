// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Moriohs Shaders/Enviroment Shaders/Sea-Water"
{
	Properties
	{
		[ShaderOptimizerLockButton]_ShaderOptimizerEnabled("PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER", Float) = 0
		[HideInInspector][Header(MAIN OPTIONS)]_WaterColor("WaterColor", Color) = (0,0.1607843,0.1568628,0)
		[Header(MAIN OPTIONS)]_WaterColor("WaterColor", Color) = (0,0.1607843,0.1568628,0)
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 2
		_WaterDepth("Water Depth", Range( 0 , 1)) = 0.975
		_NormalMapDepthinfluence("Normal Map Depth influence", Range( 0 , 1)) = 0.2
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.94
		[HideInInspector]_UVTiling("UV Tiling", Float) = 0.01
		_UVTiling("UV Tiling", Float) = 0.01
		_GeneralFoamAmount("General Foam Amount", Range( 0 , 1)) = 0.25
		_GeneralFoamStrength("General Foam Strength", Float) = 1.65
		_GeneralFoamDepthFalloff("General Foam Depth Falloff", Range( 0 , 1)) = 0.25
		[Space(25)][Header(NORMAL MAPS)]_Normal("Normal", 2D) = "bump" {}
		_ScrollSpeed("Scroll Speed", Range( -2 , 2)) = 0.075
		_NormalScale("Normal Scale", Range( -2 , 2)) = 0.2
		_VectorXY("Vector X,Y", Vector) = (0,-1,0,0)
		_SecondaryNormal("Secondary Normal", 2D) = "bump" {}
		_SecondaryScrollSpeed("Secondary Scroll Speed", Range( -2 , 2)) = 0.17
		_NormalScaleSecondary("Normal Scale Secondary", Range( -2 , 2)) = 0.2
		_SecondaryVectorXY("Secondary Vector X,Y", Vector) = (0,-1,0,0)
		[Space(25)][Header(EDGE FOAM)]_SeaFoam("SeaFoam", 2D) = "black" {}
		_EdgeFoamSpeed("Edge Foam Speed", Float) = 0.025
		_EdgePower("Edge Intensity", Range( 0 , 1)) = 0.5
		_EdgeDistance("Edge Distance", Range( 0 , 1)) = 0.7
		_WaveTessHeightinfluence("Wave Tess Height influence", Float) = 1
		[Space(25)][Header(CAUSTICS)]_CausticsTex("Caustics Tex", 2D) = "black" {}
		_CausticSpeed("Caustic Speed", Float) = 0.375
		_CausticIntensity("Caustic Intensity", Range( 0 , 2)) = 1
		_CausticDepth("Caustic Depth", Range( 0 , 1)) = 0.5
		[Space(25)][Header(TESSELATION AND WAVE SETTINGS)]_WaveStrength("Wave Strength", Float) = 1.1
		_GeneralHeight("General Height", Float) = -6
		_WaveSpeed("Wave Speed", Range( 0 , 10)) = 1.5
		_WaveTilingOffset("Wave Tiling Offset", Vector) = (1,1,0,0)
		[Header(Gerstner Waves (replaces Wave settings above))][Toggle(_GERSTNERWAVESTOGGLE_ON)] _GerstnerWavesToggle("Gerstner Waves Toggle", Float) = 0
		_WaveA("WaveA dir, dir, steepness, wavelength", Vector) = (1,0,0.5,10)
		_WaveB("WaveB dir, dir, steepness, wavelength", Vector) = (0,1,0.25,20)
		_WaveC("WaveC dir, dir, steepness, wavelength", Vector) = (1,1,0.15,10)
		_GerstnerHeight("Gerstner Height", Float) = 0
		_GerstnerSpeed("Gerstner Speed", Range( 0 , 1)) = 0.05
		_VertexOffsetMask("Vertex Offset Mask", 2D) = "white" {}
		[IntRange]_TessValue("TessValue", Range( 1 , 100)) = 1
		_TessMin("Tess Min Distance", Float) = 1
		_TessMax("Tess Max Distance", Float) = 5000
		_VertOffsetDistMaskTessMaxxthis("Vert Offset Dist Mask TessMax x this", Range( 0 , 2)) = 0.85
		[HideInInspector][ToggleUI]_NormalScaleAnimated("Normal Scale Animated", Int) = 1
		[HideInInspector][ToggleUI]_NormalScaleSecondaryAnimated("Normal Scale Secondary Animated", Int) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+51" "PreviewType"="Plane" }
		Cull [_CullMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma shader_feature_local _GERSTNERWAVESTOGGLE_ON
		SamplerState sampler_CameraDepthTexture;
		#ifndef SHADER_TARGET_SURFACE_ANALYSIS
		Texture2D _CameraDepthTexture;
		#else //Do not remove comment, itll break the shader1
		UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
		#endif //Do not remove comment, itll break the shader1
		uniform float4 _CameraDepthTexture_TexelSize;
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred nolightmap  nodynlightmap nodirlightmap nometa vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float _UVTiling;
		uniform float _CullMode;
		uniform float _ShaderOptimizerEnabled;
		uniform int _NormalScaleAnimated;
		uniform int _NormalScaleSecondaryAnimated;
		uniform float _WaveSpeed;
		uniform float2 _VectorXY;
		uniform float4 _WaveTilingOffset;
		uniform float _WaveStrength;
		uniform float _GeneralHeight;
		uniform float4 _WaveA;
		uniform sampler2D _VertexOffsetMask;
		uniform float4 _VertexOffsetMask_ST;
		uniform float _GerstnerSpeed;
		uniform float _GerstnerHeight;
		uniform float4 _WaveB;
		uniform float4 _WaveC;
		uniform float _TessMin;
		uniform float _TessMax;
		uniform float _VertOffsetDistMaskTessMaxxthis;
		uniform float _TessValue;
		uniform sampler2D _Normal;
		uniform float _ScrollSpeed;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform sampler2D _SecondaryNormal;
		uniform float _SecondaryScrollSpeed;
		uniform float2 _SecondaryVectorXY;
		uniform float4 _SecondaryNormal_ST;
		uniform float _NormalScaleSecondary;
		uniform float4 _WaterColor;
		uniform float _WaterDepth;
		uniform sampler2D _CausticsTex;
		uniform float4 _CausticsTex_ST;
		uniform float _CausticSpeed;
		uniform float _CausticDepth;
		uniform float _CausticIntensity;
		uniform float _GeneralFoamStrength;
		uniform float _GeneralFoamAmount;
		uniform float _GeneralFoamDepthFalloff;
		uniform sampler2D _SeaFoam;
		uniform float4 _SeaFoam_ST;
		uniform float _EdgeFoamSpeed;
		uniform float _WaveTessHeightinfluence;
		uniform float _EdgeDistance;
		uniform float _EdgePower;
		uniform float _Smoothness;
		uniform float _NormalMapDepthinfluence;


		float2 hash2D2D( float2 s )
		{
			return frac(sin(fmod(float2(dot(s, float2(127.1,311.7)), dot(s, float2(269.5,183.3))), 3.14159))*43758.5453);
		}


		void SourceDeclaration(  )
		{
			//This Shader was made possible by Moriohs Toon Shader (https://gitlab.com/xMorioh/moriohs-toon-shader)
		}


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
		}


		float3 GerstnerWave( float4 wave, float3 p, inout float3 tangent, inout float3 binormal, float Speed, float Height )
		{
			// Source: https://catlikecoding.com/unity/tutorials/flow/waves
			float steepness = wave.z;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, p.xz) - c * _Time.y * Speed);
			float a = steepness / k;
			tangent += float3(
				-d.x * d.x * (steepness * sin(f)),
				d.x * (steepness * cos(f)),
				-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
				-d.x * d.y * (steepness * sin(f)),
				d.y * (steepness * cos(f)),
				-d.y * d.y * (steepness * sin(f))
			);
			return float3(
				d.x * (a * cos(f)),
				a * sin(f) * Height,
				d.y * (a * cos(f))
			);
		}


		float TessDistance( float4 vertex, float minDist, float maxDist, float tess )
		{
			return UnityCalcDistanceTessFactor(vertex, minDist, maxDist, tess);
		}


		float3 tex2DStochasticNormals( sampler2D tex, float2 UV, float _NormalScale )
		{
			    //triangle vertices and blend weights
			    //BW_vx[0...2].xyz = triangle verts
			    //BW_vx[3].xy = blend weights (z is unused)
			    float4x3 BW_vx;
			    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
			    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464);
			    //vertex IDs and barycentric coords
			    float2 vxID = float2 (floor(skewUV));
			    float3 barry = float3 (frac(skewUV), 0);
			    barry.z = 1.0-barry.x-barry.y;
			    BW_vx = ((barry.z>0) ? 
			        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :
			        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)));
			    //calculate derivatives to avoid triangular grid artifacts
			    float2 dx = ddx(UV);
			    float2 dy = ddy(UV);
			    //blend samples with calculated weights
			    return mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), _NormalScale), BW_vx[3].x) + 
			            mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), _NormalScale), BW_vx[3].y) + 
			            mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), _NormalScale), BW_vx[3].z);
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir1500( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		float4 tex2DStochastic( sampler2D tex, float2 UV )
		{
			    //triangle vertices and blend weights
			    //BW_vx[0...2].xyz = triangle verts
			    //BW_vx[3].xy = blend weights (z is unused)
			    float4x3 BW_vx;
			    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
			    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464);
			    //vertex IDs and barycentric coords
			    float2 vxID = float2 (floor(skewUV));
			    float3 barry = float3 (frac(skewUV), 0);
			    barry.z = 1.0-barry.x-barry.y;
			    BW_vx = ((barry.z>0) ? 
			        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :
			        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)));
			    //calculate derivatives to avoid triangular grid artifacts
			    float2 dx = ddx(UV);
			    float2 dy = ddy(UV);
			    //blend samples with calculated weights
			    return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + 
			            mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + 
			            mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z);
		}


		half3 Ambient(  )
		{
			return float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + float3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin,_TessMax,_TessValue);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime415 = _Time.y * ( _WaveSpeed * 10.0 );
			float2 NormalVector625 = _VectorXY;
			float2 appendResult1000 = (float2(_WaveTilingOffset.x , _WaveTilingOffset.y));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult1625 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult1001 = (float2(_WaveTilingOffset.z , _WaveTilingOffset.w));
			float2 temp_output_1003_0 = ( ( appendResult1000 * appendResult1625 ) + appendResult1001 );
			float2 panner412 = ( mulTime415 * ( 1.0 - NormalVector625 ) + temp_output_1003_0);
			float simpleNoise411 = SimpleNoise( panner412*0.01 );
			float temp_output_468_0 = ( _WaveStrength * 100.0 );
			float temp_output_488_0 = ( _GeneralHeight * 10.0 );
			float2 panner746 = ( mulTime415 * NormalVector625 + temp_output_1003_0);
			float simpleNoise747 = SimpleNoise( panner746*0.01 );
			float3 appendResult424 = (float3(0.0 , ( ( ( ( simpleNoise411 * temp_output_468_0 ) + temp_output_488_0 ) + ( ( simpleNoise747 * temp_output_468_0 ) + temp_output_488_0 ) ) * 0.5 ) , 0.0));
			float3 NoiseVertOffset1257 = appendResult424;
			float2 uv_VertexOffsetMask = v.texcoord * _VertexOffsetMask_ST.xy + _VertexOffsetMask_ST.zw;
			float4 tex2DNode1275 = tex2Dlod( _VertexOffsetMask, float4( uv_VertexOffsetMask, 0, 0.0) );
			float VertexOffsetMask1284 = tex2DNode1275.g;
			float4 appendResult1278 = (float4(_WaveA.x , _WaveA.y , ( _WaveA.z * VertexOffsetMask1284 ) , _WaveA.w));
			float4 wave1199 = appendResult1278;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 p1199 = ase_vertex3Pos;
			float3 _tangent = float3(1,0,0);
			float3 tangent1199 = _tangent;
			float3 _binormal = float3(0,0,1);
			float3 binormal1199 = _binormal;
			float Speed1199 = _GerstnerSpeed;
			float temp_output_1243_0 = ( _GerstnerHeight * 100.0 );
			float Height1199 = temp_output_1243_0;
			float3 localGerstnerWave1199 = GerstnerWave( wave1199 , p1199 , tangent1199 , binormal1199 , Speed1199 , Height1199 );
			float4 appendResult1282 = (float4(_WaveB.x , _WaveB.y , ( _WaveB.z * VertexOffsetMask1284 ) , _WaveB.w));
			float4 wave1200 = appendResult1282;
			float3 p1200 = ase_vertex3Pos;
			float3 tangent1200 = _tangent;
			float3 binormal1200 = _binormal;
			float Speed1200 = _GerstnerSpeed;
			float Height1200 = temp_output_1243_0;
			float3 localGerstnerWave1200 = GerstnerWave( wave1200 , p1200 , tangent1200 , binormal1200 , Speed1200 , Height1200 );
			float4 appendResult1283 = (float4(_WaveC.x , _WaveC.y , ( _WaveC.z * VertexOffsetMask1284 ) , _WaveC.w));
			float4 wave1201 = appendResult1283;
			float3 p1201 = ase_vertex3Pos;
			float3 tangent1201 = _tangent;
			float3 binormal1201 = _binormal;
			float Speed1201 = _GerstnerSpeed;
			float Height1201 = temp_output_1243_0;
			float3 localGerstnerWave1201 = GerstnerWave( wave1201 , p1201 , tangent1201 , binormal1201 , Speed1201 , Height1201 );
			float3 GerstnerOffset1259 = ( localGerstnerWave1199 + localGerstnerWave1200 + localGerstnerWave1201 );
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float3 staticSwitch1249 = GerstnerOffset1259;
			#else
				float3 staticSwitch1249 = NoiseVertOffset1257;
			#endif
			float4 ase_vertex4Pos = v.vertex;
			float4 vertex1675 = ase_vertex4Pos;
			float minDist1675 = _TessMin;
			float maxDist1675 = ( _TessMax * _VertOffsetDistMaskTessMaxxthis );
			float tess1675 = _TessValue;
			float localTessDistance1675 = TessDistance( vertex1675 , minDist1675 , maxDist1675 , tess1675 );
			float TessellationDistance1688 = saturate( (0.0 + (localTessDistance1675 - ( _TessValue / 100.0 )) * (1.0 - 0.0) / (1.0 - ( _TessValue / 100.0 ))) );
			float3 FinalVertexOffset1260 = ( ( staticSwitch1249 * tex2DNode1275.g ) * TessellationDistance1688 );
			v.vertex.xyz += FinalVertexOffset1260;
			v.vertex.w = 1;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 normalizeResult1209 = normalize( cross( ( binormal1199 + binormal1200 + binormal1201 ) , ( tangent1199 + tangent1200 + tangent1201 ) ) );
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float3 staticSwitch1254 = normalizeResult1209;
			#else
				float3 staticSwitch1254 = ase_vertexNormal;
			#endif
			float3 FinalVertexNormals1262 = staticSwitch1254;
			v.normal = FinalVertexNormals1262;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			sampler2D tex96_g170 = _Normal;
			float mulTime7_g170 = _Time.y * _ScrollSpeed;
			float temp_output_68_0_g170 = _UVTiling;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult105_g170 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_104_0_g170 = ( ( _Normal_ST.xy * temp_output_68_0_g170 * appendResult105_g170 ) + _Normal_ST.zw );
			float2 panner17_g170 = ( mulTime7_g170 * _VectorXY + temp_output_104_0_g170);
			float2 UV96_g170 = ( panner17_g170 + 0.25 );
			float _NormalScale96_g170 = _NormalScale;
			float3 localtex2DStochasticNormals96_g170 = tex2DStochasticNormals( tex96_g170 , UV96_g170 , _NormalScale96_g170 );
			sampler2D tex79_g170 = _Normal;
			float mulTime4_g170 = _Time.y * _ScrollSpeed;
			float2 panner12_g170 = ( ( mulTime4_g170 * 2.179 ) * _VectorXY + ( 1.0 - temp_output_104_0_g170 ));
			float2 UV79_g170 = ( 1.0 - panner12_g170 );
			float _NormalScale79_g170 = _NormalScale;
			float3 localtex2DStochasticNormals79_g170 = tex2DStochasticNormals( tex79_g170 , UV79_g170 , _NormalScale79_g170 );
			sampler2D tex76_g170 = _SecondaryNormal;
			float mulTime16_g170 = _Time.y * _SecondaryScrollSpeed;
			float2 panner21_g170 = ( mulTime16_g170 * _SecondaryVectorXY + ( ( _SecondaryNormal_ST.xy * temp_output_68_0_g170 * appendResult105_g170 ) + _SecondaryNormal_ST.zw ));
			float2 UV76_g170 = panner21_g170;
			float _NormalScale76_g170 = _NormalScaleSecondary;
			float3 localtex2DStochasticNormals76_g170 = tex2DStochasticNormals( tex76_g170 , UV76_g170 , _NormalScale76_g170 );
			float3 normalizeResult66_g170 = normalize( BlendNormals( BlendNormals( localtex2DStochasticNormals96_g170 , localtex2DStochasticNormals79_g170 ) , localtex2DStochasticNormals76_g170 ) );
			float3 Normals80 = normalizeResult66_g170;
			o.Normal = Normals80;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV888 = dot( normalize( (WorldNormalVector( i , Normals80 )) ), ase_worldViewDir );
			float fresnelNode888 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV888, 5.0 ) );
			float localDepthCheck1430 = ( 0.0 );
			float width1430 = 17;
			{
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			_CameraDepthTexture.GetDimensions(width1430, width1430);
			#endif
			}
			float localscreenDepth1634 = ( 0.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 SP1634 = ase_screenPosNorm;
			float ScreenDepth1634 = 0;
			{
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			ScreenDepth1634 = LinearEyeDepth(_CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP1634.xy));
			#else
			ScreenDepth1634 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP1634.xy ));
			#endif
			}
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_viewPos = UnityObjectToViewPos( ase_vertex4Pos );
			float ase_screenDepth = -ase_viewPos.z;
			float ifLocalVar1458 = 0;
			if( width1430 <= 16.0 )
				ifLocalVar1458 = 1.0;
			else
				ifLocalVar1458 = ( ( ScreenDepth1634 - ase_screenDepth ) * ( 1.0 - _WaterDepth ) );
			float WaterDepth671 = ifLocalVar1458;
			float4 lerpResult894 = lerp( _WaterColor , ( _WaterColor * fresnelNode888 ) , saturate( ( WaterDepth671 * 0.5 ) ));
			float localDepthCheck1518 = ( 0.0 );
			float width1518 = 17;
			{
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			_CameraDepthTexture.GetDimensions(width1518, width1518);
			#endif
			}
			sampler2D tex568 = _CausticsTex;
			float2 UV22_g171 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g171 = UnStereo( UV22_g171 );
			float2 break1512 = localUnStereo22_g171;
			float localscreenDepth1515 = ( 0.0 );
			float4 SP1515 = ase_screenPosNorm;
			float ScreenDepth1515 = 0;
			{
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			ScreenDepth1515 = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP1515.xy);
			#else
			ScreenDepth1515 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP1515.xy );
			#endif
			}
			#ifdef UNITY_REVERSED_Z
				float staticSwitch1509 = ( 1.0 - ScreenDepth1515 );
			#else
				float staticSwitch1509 = ScreenDepth1515;
			#endif
			float3 appendResult1508 = (float3(break1512.x , break1512.y , staticSwitch1509));
			float4 appendResult1506 = (float4((appendResult1508*2.0 + -1.0) , 1.0));
			float4 temp_output_1504_0 = mul( unity_CameraInvProjection, appendResult1506 );
			float3 In1500 = ( (temp_output_1504_0).xyz / (temp_output_1504_0).w );
			float3 localInvertDepthDir1500 = InvertDepthDir1500( In1500 );
			float4 appendResult1498 = (float4(localInvertDepthDir1500 , 1.0));
			float2 temp_output_1397_0 = ( ( _CausticsTex_ST.xy / 150.0 ) * (mul( unity_CameraToWorld, appendResult1498 )).xz );
			float NormalSpeed633 = ( _ScrollSpeed * 2.179 );
			float mulTime1391 = _Time.y * ( NormalSpeed633 * _CausticSpeed );
			float2 NormalVector625 = _VectorXY;
			float2 UV568 = ( temp_output_1397_0 + ( mulTime1391 * NormalVector625 ) + _CausticsTex_ST.zw );
			float4 localtex2DStochastic568 = tex2DStochastic( tex568 , UV568 );
			sampler2D tex1410 = _CausticsTex;
			float2 UV1410 = ( temp_output_1397_0 + ( mulTime1391 * ( 1.0 - NormalVector625 ) ) + _CausticsTex_ST.zw );
			float4 localtex2DStochastic1410 = tex2DStochastic( tex1410 , UV1410 );
			float temp_output_547_0 = ( 1.0 - saturate( ( WaterDepth671 * ( 1.0 - _CausticDepth ) ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			half3 localAmbient865 = Ambient();
			float4 lerpResult869 = lerp( ( _WaterColor * 2.0 ) , float4( ( ase_lightColor.rgb + localAmbient865 ) , 0.0 ) , saturate( temp_output_547_0 ));
			float4 ifLocalVar1519 = 0;
			if( width1518 > 16.0 )
				ifLocalVar1519 = ( saturate( ( localtex2DStochastic568.y * localtex2DStochastic1410.y * temp_output_547_0 ) ) * lerpResult869 * _CausticIntensity );
			float4 Caustics621 = ifLocalVar1519;
			float mulTime415 = _Time.y * ( _WaveSpeed * 10.0 );
			float2 appendResult1000 = (float2(_WaveTilingOffset.x , _WaveTilingOffset.y));
			float2 appendResult1625 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult1001 = (float2(_WaveTilingOffset.z , _WaveTilingOffset.w));
			float2 temp_output_1003_0 = ( ( appendResult1000 * appendResult1625 ) + appendResult1001 );
			float2 panner412 = ( mulTime415 * ( 1.0 - NormalVector625 ) + temp_output_1003_0);
			float simpleNoise411 = SimpleNoise( panner412*0.01 );
			float2 panner746 = ( mulTime415 * NormalVector625 + temp_output_1003_0);
			float simpleNoise747 = SimpleNoise( panner746*0.01 );
			float temp_output_928_0 = ( simpleNoise411 + simpleNoise747 );
			float2 uv_VertexOffsetMask = i.uv_texcoord * _VertexOffsetMask_ST.xy + _VertexOffsetMask_ST.zw;
			float4 tex2DNode1275 = tex2D( _VertexOffsetMask, uv_VertexOffsetMask );
			float VertexOffsetMask1284 = tex2DNode1275.g;
			float4 appendResult1278 = (float4(_WaveA.x , _WaveA.y , ( _WaveA.z * VertexOffsetMask1284 ) , _WaveA.w));
			float4 wave1199 = appendResult1278;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 p1199 = ase_vertex3Pos;
			float3 _tangent = float3(1,0,0);
			float3 tangent1199 = _tangent;
			float3 _binormal = float3(0,0,1);
			float3 binormal1199 = _binormal;
			float Speed1199 = _GerstnerSpeed;
			float temp_output_1243_0 = ( _GerstnerHeight * 100.0 );
			float Height1199 = temp_output_1243_0;
			float3 localGerstnerWave1199 = GerstnerWave( wave1199 , p1199 , tangent1199 , binormal1199 , Speed1199 , Height1199 );
			float4 appendResult1282 = (float4(_WaveB.x , _WaveB.y , ( _WaveB.z * VertexOffsetMask1284 ) , _WaveB.w));
			float4 wave1200 = appendResult1282;
			float3 p1200 = ase_vertex3Pos;
			float3 tangent1200 = _tangent;
			float3 binormal1200 = _binormal;
			float Speed1200 = _GerstnerSpeed;
			float Height1200 = temp_output_1243_0;
			float3 localGerstnerWave1200 = GerstnerWave( wave1200 , p1200 , tangent1200 , binormal1200 , Speed1200 , Height1200 );
			float4 appendResult1283 = (float4(_WaveC.x , _WaveC.y , ( _WaveC.z * VertexOffsetMask1284 ) , _WaveC.w));
			float4 wave1201 = appendResult1283;
			float3 p1201 = ase_vertex3Pos;
			float3 tangent1201 = _tangent;
			float3 binormal1201 = _binormal;
			float Speed1201 = _GerstnerSpeed;
			float Height1201 = temp_output_1243_0;
			float3 localGerstnerWave1201 = GerstnerWave( wave1201 , p1201 , tangent1201 , binormal1201 , Speed1201 , Height1201 );
			float3 GerstnerOffset1259 = ( localGerstnerWave1199 + localGerstnerWave1200 + localGerstnerWave1201 );
			float dotResult1246 = dot( GerstnerOffset1259 , Normals80 );
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float staticSwitch1255 = ( saturate( GerstnerOffset1259.y ) * dotResult1246 );
			#else
				float staticSwitch1255 = temp_output_928_0;
			#endif
			float EdgeFoamTessHeightInfluence934 = staticSwitch1255;
			float3 temp_cast_2 = (EdgeFoamTessHeightInfluence934).xxx;
			float dotResult1179 = dot( Normals80 , temp_cast_2 );
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float staticSwitch1616 = EdgeFoamTessHeightInfluence934;
			#else
				float staticSwitch1616 = dotResult1179;
			#endif
			float GeneralFoam673 = saturate( ( ( ( staticSwitch1616 * _GeneralFoamStrength * _GeneralFoamAmount ) - ( _GeneralFoamStrength * ( 1.0 - _GeneralFoamAmount ) ) ) * saturate( ( WaterDepth671 * _GeneralFoamDepthFalloff ) ) ) );
			float localDepthCheck1486 = ( 0.0 );
			float width1486 = 17;
			{
			#ifndef SHADER_TARGET_SURFACE_ANALYSIS
			_CameraDepthTexture.GetDimensions(width1486, width1486);
			#endif
			}
			sampler2D tex340 = _SeaFoam;
			float2 appendResult1617 = (float2(ase_worldPos.x , ase_worldPos.z));
			float mulTime344 = _Time.y * _EdgeFoamSpeed;
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float staticSwitch1256 = 0.0;
			#else
				float staticSwitch1256 = EdgeFoamTessHeightInfluence934;
			#endif
			float2 UV340 = ( ( ( _SeaFoam_ST.xy * appendResult1617 * _UVTiling ) + _SeaFoam_ST.zw ) + ( mulTime344 * NormalVector625 ) + ( ( staticSwitch1256 * _WaveTessHeightinfluence ) + 0.0 ) );
			float4 localtex2DStochastic340 = tex2DStochastic( tex340 , UV340 );
			float Noise1655 = temp_output_928_0;
			float smoothstepResult1670 = smoothstep( -50.0 , 50.0 , GerstnerOffset1259.y);
			#ifdef _GERSTNERWAVESTOGGLE_ON
				float staticSwitch1672 = smoothstepResult1670;
			#else
				float staticSwitch1672 = Noise1655;
			#endif
			float ifLocalVar1483 = 0;
			if( width1486 > 16.0 )
				ifLocalVar1483 = ( saturate( ( localtex2DStochastic340.y - saturate( ( WaterDepth671 * _EdgeDistance ) ) ) ) * _EdgePower * saturate( staticSwitch1672 ) );
			float EdgeFoam1637 = ifLocalVar1483;
			o.Albedo = ( lerpResult894 + ( Caustics621 + GeneralFoam673 + EdgeFoam1637 ) ).rgb;
			o.Smoothness = ( saturate( ( 1.0 - ( EdgeFoam1637 + GeneralFoam673 ) ) ) * _Smoothness );
			o.Alpha = saturate( ( WaterDepth671 + ( Normals80.y * _NormalMapDepthinfluence ) ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1553;30;2106;954;-1801.737;-470.4507;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1277;6064,1488;Inherit;False;1170;287;;6;1689;1679;1260;1276;1284;1275;Final Vertex Offset with Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1275;6112,1536;Inherit;True;Property;_VertexOffsetMask;Vertex Offset Mask;42;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1284;6432,1632;Inherit;False;VertexOffsetMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1265;3536,1408;Inherit;False;2449.882;791.8042;;31;1262;1254;1251;1249;1209;1258;1210;1213;1212;1259;1211;1199;1201;1200;1203;1228;1202;1205;1243;1282;1278;1283;1244;1242;1279;1281;1280;1207;1208;1206;1285;GerstnerWave;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;82;-416,1408;Inherit;False;852.0675;471.4516;;7;1624;1623;1422;1423;633;80;625;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1285;3984,2112;Inherit;False;1284;VertexOffsetMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;1206;3904,1536;Inherit;False;Property;_WaveA;WaveA dir, dir, steepness, wavelength;37;0;Create;False;0;0;0;False;0;False;1,0,0.5,10;0,1,0.5,0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;1207;3904,1728;Inherit;False;Property;_WaveB;WaveB dir, dir, steepness, wavelength;38;0;Create;False;0;0;0;False;0;False;0,1,0.25,20;1,1,0.35,0.0135;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;1208;3904,1920;Inherit;False;Property;_WaveC;WaveC dir, dir, steepness, wavelength;39;0;Create;False;0;0;0;False;0;False;1,1,0.15,10;1,1,0.25,0.0065;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;543;560,1392;Inherit;False;2790.646;838.767;Offset;44;1626;1625;1257;424;751;822;750;749;484;540;748;488;468;489;479;469;427;934;1255;1274;1269;928;1273;1246;1271;747;1248;411;1264;412;438;746;1003;415;441;743;626;999;1001;416;1000;998;1627;1655;For Tesselated Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1244;3616,1920;Inherit;False;Constant;_Float2;Float 2;36;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1281;4240,1984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1280;4240,1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1242;3584,1824;Inherit;False;Property;_GerstnerHeight;Gerstner Height;40;0;Create;True;0;0;0;False;0;False;0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1279;4240,1600;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1624;-352,1472;Inherit;False;Property;_UVTiling;UV Tiling;7;1;[HideInInspector];Fetch;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1283;4368,1920;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;1203;4496,1920;Inherit;False;Constant;_binormal;binormal;32;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;1282;4368,1728;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;1278;4368,1536;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1228;4400,1472;Inherit;False;Property;_GerstnerSpeed;Gerstner Speed;41;0;Create;True;0;0;0;False;0;False;0.05;0.005;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1243;3776,1856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1202;4496,1728;Inherit;False;Constant;_tangent;tangent;32;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;1205;4496,1536;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;1626;608,1968;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;998;752,1776;Inherit;False;Property;_WaveTilingOffset;Wave Tiling Offset;35;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,5,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1623;-208,1472;Inherit;False;Normal scroll;11;;170;8e7734c034edf454cad15a4da30f1093;0;1;68;FLOAT;0;False;5;FLOAT3;0;FLOAT2;83;FLOAT;87;FLOAT2;98;FLOAT;97
Node;AmplifyShaderEditor.CommentaryNode;1516;-2832,2416;Inherit;False;2692.017;556.1323;Reconstruct World Pos from Depth;21;1510;1515;1497;1498;1499;1500;1501;1503;1502;1504;1506;1505;1507;1508;1512;1509;1513;1514;1376;1367;1583;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;1201;4720,1920;Inherit;False;// Source: https://catlikecoding.com/unity/tutorials/flow/waves$float steepness = wave.z@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, p.xz) - c * _Time.y * Speed)@$float a = steepness / k@$tangent += float3($	-d.x * d.x * (steepness * sin(f)),$	d.x * (steepness * cos(f)),$	-d.x * d.y * (steepness * sin(f))$)@$binormal += float3($	-d.x * d.y * (steepness * sin(f)),$	d.y * (steepness * cos(f)),$	-d.y * d.y * (steepness * sin(f))$)@$return float3($	d.x * (a * cos(f)),$	a * sin(f) * Height,$	d.y * (a * cos(f))$)@;3;Create;6;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;True;p;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;0,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,0;InOut;;Inherit;False;True;Speed;FLOAT;0;In;;Inherit;False;True;Height;FLOAT;0;In;;Inherit;False;GerstnerWave;False;False;0;;False;6;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT3;0;FLOAT3;3;FLOAT3;4
Node;AmplifyShaderEditor.RangedFloatNode;416;752,1584;Inherit;False;Property;_WaveSpeed;Wave Speed;34;0;Create;True;0;0;0;False;0;False;1.5;2.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1200;4720,1728;Inherit;False;// Source: https://catlikecoding.com/unity/tutorials/flow/waves$float steepness = wave.z@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, p.xz) - c * _Time.y * Speed)@$float a = steepness / k@$tangent += float3($	-d.x * d.x * (steepness * sin(f)),$	d.x * (steepness * cos(f)),$	-d.x * d.y * (steepness * sin(f))$)@$binormal += float3($	-d.x * d.y * (steepness * sin(f)),$	d.y * (steepness * cos(f)),$	-d.y * d.y * (steepness * sin(f))$)@$return float3($	d.x * (a * cos(f)),$	a * sin(f) * Height,$	d.y * (a * cos(f))$)@;3;Create;6;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;True;p;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;0,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,0;InOut;;Inherit;False;True;Speed;FLOAT;0;In;;Inherit;False;True;Height;FLOAT;0;In;;Inherit;False;GerstnerWave;False;False;0;;False;6;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT3;0;FLOAT3;3;FLOAT3;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;1514;-2784,2720;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;625;144,1552;Inherit;False;NormalVector;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;1000;944,1776;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;1199;4720,1536;Inherit;False;// Source: https://catlikecoding.com/unity/tutorials/flow/waves$float steepness = wave.z@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, p.xz) - c * _Time.y * Speed)@$float a = steepness / k@$tangent += float3($	-d.x * d.x * (steepness * sin(f)),$	d.x * (steepness * cos(f)),$	-d.x * d.y * (steepness * sin(f))$)@$binormal += float3($	-d.x * d.y * (steepness * sin(f)),$	d.y * (steepness * cos(f)),$	-d.y * d.y * (steepness * sin(f))$)@$return float3($	d.x * (a * cos(f)),$	a * sin(f) * Height,$	d.y * (a * cos(f))$)@;3;Create;6;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;True;p;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;0,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,0;InOut;;Inherit;False;True;Speed;FLOAT;0;In;;Inherit;False;True;Height;FLOAT;0;In;;Inherit;False;GerstnerWave;False;False;0;;False;6;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT3;0;FLOAT3;3;FLOAT3;4
Node;AmplifyShaderEditor.DynamicAppendNode;1625;768,2000;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1211;4992,1600;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;999;1072,1776;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;1001;944,1872;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;626;1008,1472;Inherit;False;625;NormalVector;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1627;1040,1584;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1515;-2560,2800;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$ScreenDepth = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP.xy)@$#else$ScreenDepth = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP.xy )@$#endif;1;Call;2;True;SP;FLOAT4;0,0,0,0;In;;Inherit;False;True;ScreenDepth;FLOAT;0;Out;;Inherit;False;screenDepth;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;1510;-2336,2880;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1003;1200,1776;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;441;1184,1472;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1259;5120,1600;Inherit;False;GerstnerOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1513;-2560,2640;Inherit;False;Non Stereo Screen Pos;-1;;171;1731ee083b93c104880efc701e11b49b;0;1;23;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;743;1168,2016;Inherit;False;625;NormalVector;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;415;1168,1584;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1509;-2192,2816;Float;False;Property;_Keyword0;Keyword 0;3;0;Fetch;True;0;0;0;False;0;False;0;0;0;False;UNITY_REVERSED_Z;Toggle;2;Key0;Key1;Fetch;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1512;-2256,2640;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;1264;2160,1552;Inherit;False;1259;GerstnerOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;144,1472;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;746;1360,2000;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;412;1360,1456;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;438;1376,1584;Inherit;False;Constant;_WaveTiling;Wave Tiling;26;0;Create;True;0;0;0;False;0;False;0.01;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1508;-1920,2640;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1271;2352,1456;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;1248;2176,1648;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;411;1552,1456;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;747;1552,2000;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1246;2352,1584;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1507;-1760,2640;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;928;2048,1584;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1273;2480,1488;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraProjectionNode;1505;-1648,2544;Inherit;False;unity_CameraInvProjection;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1269;2624,1488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1506;-1536,2640;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;1274;2704,1600;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;1447;1344,432;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1504;-1360,2608;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;1255;2752,1488;Inherit;False;Property;_GerstnerWaves;Gerstner Waves;36;0;Create;True;0;0;0;False;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Reference;1249;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1502;-1200,2656;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1503;-1200,2544;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;934;3040,1488;Inherit;False;EdgeFoamTessHeightInfluence;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;1472,608;Inherit;False;Property;_WaterDepth;Water Depth;4;0;Create;True;0;0;0;True;0;False;0.975;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;1628;1520,528;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1634;1552,416;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$ScreenDepth = LinearEyeDepth(_CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP.xy))@$#else$ScreenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP.xy ))@$#endif;1;Call;2;True;SP;FLOAT4;0,0,0,0;In;;Inherit;False;True;ScreenDepth;FLOAT;0;Out;;Inherit;False;screenDepth;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;95;-1529.268,240;Inherit;False;2789.058;803.8375;;36;1656;1637;1483;1641;1486;54;55;1640;1649;372;340;1648;1639;924;52;1621;923;939;1620;344;631;940;346;1622;1617;941;1619;1256;1618;935;87;1672;1673;1674;1670;1671;EdgeFoam;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;1636;1744,608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;87;-1472,288;Inherit;True;Property;_SeaFoam;SeaFoam;21;0;Create;True;0;0;0;False;2;Space(25);Header(EDGE FOAM);False;0066da7fc33808048a085ab52a41c20a;0066da7fc33808048a085ab52a41c20a;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1630;1792,480;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1618;-1216,464;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;1501;-960,2592;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;935;-1200,768;Inherit;False;934;EdgeFoamTessHeightInfluence;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;633;144,1632;Inherit;False;NormalSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1617;-1040,496;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;1619;-1216,368;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.CommentaryNode;632;-80,2256;Inherit;False;3446.054;1071.46;;42;1518;1519;621;694;696;588;869;591;550;832;548;849;1427;864;850;569;623;547;865;1411;1410;568;570;1388;1318;1415;1333;1407;601;1319;1419;1397;1391;1399;600;1420;1400;628;1425;1426;629;1646;Caustics;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;1500;-816,2544;Inherit;False;float3 result = In@$#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301$result *= float3(1,1,-1)@$#endif$return result@;3;Create;1;True;In;FLOAT3;0,0,0;In;;Inherit;False;InvertDepthDir;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1256;-928,768;Inherit;False;Property;_GerstnerWaves;Gerstner Waves;36;0;Create;True;0;0;0;False;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Reference;1249;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;346;-880,608;Inherit;False;Property;_EdgeFoamSpeed;Edge Foam Speed;22;0;Create;True;1;EDGE FOAM;0;0;False;0;False;0.025;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1430;2016,368;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$_CameraDepthTexture.GetDimensions(width, width)@$#endif;1;Call;1;True;width;FLOAT;17;InOut;;Inherit;False;DepthCheck;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;17;False;2;FLOAT;0;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1631;1936,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;941;-912,864;Inherit;False;Property;_WaveTessHeightinfluence;Wave Tess Height influence;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1477;2064,560;Inherit;False;Constant;_Float9;Float 9;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1622;-1040,592;Inherit;False;Property;_UVTiling;UV Tiling;9;1;[HideInInspector];Fetch;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1426;112,2608;Inherit;False;633;NormalSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;940;-640,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.333;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1458;2224,432;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;16;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;629;112,2688;Inherit;False;Property;_CausticSpeed;Caustic Speed;27;0;Create;True;0;0;0;False;0;False;0.375;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;344;-688,592;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1498;-656,2544;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1620;-880,496;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CameraToWorldMatrix;1499;-720,2464;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;631;-752,688;Inherit;False;625;NormalVector;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;1420;656,2416;Inherit;False;570;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;1400;704,2528;Inherit;False;Constant;_Float8;Float 8;41;0;Create;True;0;0;0;False;0;False;150;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1425;656,2608;Inherit;False;625;NormalVector;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;427;1360,1680;Inherit;False;Property;_WaveStrength;Wave Strength;32;0;Create;True;1;Tesselation and Wave settings;0;0;False;2;Space(25);Header(TESSELATION AND WAVE SETTINGS);False;1.1;1.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;628;304,2640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;469;1440,1776;Inherit;False;Constant;_Float3;Float 3;19;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;670;-296.3655,-464;Inherit;False;1535.418;581.5692;;17;1175;1179;648;1616;673;655;1180;1189;642;666;675;1190;667;1191;668;1181;646;General Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;671;2384,432;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1621;-736,496;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;923;-512,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1497;-496,2496;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;939;-512,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-192,528;Inherit;False;Property;_EdgeDistance;Edge Distance;24;0;Create;True;0;0;0;True;0;False;0.7;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1175;-272,-288;Inherit;False;934;EdgeFoamTessHeightInfluence;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1673;-320,752;Inherit;False;1259;GerstnerOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;468;1632,1712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;924;-336,496;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1639;-112,448;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;601;768,2896;Inherit;False;Property;_CausticDepth;Caustic Depth;29;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1391;432,2640;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1399;864,2480;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;489;1632,1904;Inherit;False;Constant;_Float5;Float 5;20;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;479;1600,1808;Inherit;False;Property;_GeneralHeight;General Height;33;0;Create;True;0;0;0;False;0;False;-6;-6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;648;-160,-384;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;1376;-352,2496;Inherit;False;True;False;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;600;848,2608;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;540;1808,1456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1655;2160,1472;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1674;-128,752;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CustomExpressionNode;340;-80,288;Float;False;    //triangle vertices and blend weights$    //BW_vx[0...2].xyz = triangle verts$    //BW_vx[3].xy = blend weights (z is unused)$    float4x3 BW_vx@$$    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)$    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464)@$$    //vertex IDs and barycentric coords$    float2 vxID = float2 (floor(skewUV))@$    float3 barry = float3 (frac(skewUV), 0)@$    barry.z = 1.0-barry.x-barry.y@$$    BW_vx = ((barry.z>0) ? $        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :$        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)))@$$    //calculate derivatives to avoid triangular grid artifacts$    float2 dx = ddx(UV)@$    float2 dy = ddy(UV)@$$    //blend samples with calculated weights$    return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z)@;4;Create;2;True;tex;SAMPLER2D;0,0;In;;Float;False;True;UV;FLOAT2;0,0;In;;Float;False;tex2DStochastic;False;False;1;7;;False;2;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;646;32,-144;Inherit;False;Property;_GeneralFoamAmount;General Foam Amount;8;0;Create;True;0;0;0;False;0;False;0.25;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1397;992,2480;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;1179;16,-384;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1648;80,448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;748;1808,2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1319;1008,2816;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1318;1040,2896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1419;992,2576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;1792,1840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1407;992,2352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1649;208,448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1656;16,672;Inherit;False;1655;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;372;64,288;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StaticSwitch;1616;144,-384;Inherit;False;Property;_GerstnerWaves;Gerstner Waves;36;0;Create;True;0;0;0;False;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Reference;1249;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1670;16,752;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-50;False;2;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1181;272,-64;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;667;32,-224;Inherit;False;Property;_GeneralFoamStrength;General Foam Strength;9;0;Create;True;0;0;0;False;0;False;1.65;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;668;288,-144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1191;192,16;Inherit;False;Property;_GeneralFoamDepthFalloff;General Foam Depth Falloff;10;0;Create;True;0;0;0;False;0;False;0.25;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1388;1136,2352;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;570;1248,2416;Inherit;True;Property;_CausticsTex;Caustics Tex;26;0;Create;True;1;Caustics;0;0;False;2;Space(25);Header(CAUSTICS);False;81ea855dffbe787439dec7fb82f48045;81ea855dffbe787439dec7fb82f48045;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;749;1952,2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1415;1136,2576;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;484;1952,1456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1333;1200,2848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1672;176,672;Inherit;False;Property;_Keyword1;Keyword 1;36;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;1249;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1190;464,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1668;2448,912;Inherit;False;Property;_TessMax;Tess Max Distance;45;0;Create;False;0;0;0;False;0;False;5000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;448,-384;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;675;448,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1700;2336,1152;Inherit;False;Property;_VertOffsetDistMaskTessMaxxthis;Vert Offset Dist Mask TessMax x this;46;0;Create;True;0;0;0;False;0;False;0.85;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;568;1520,2320;Float;False;    //triangle vertices and blend weights$    //BW_vx[0...2].xyz = triangle verts$    //BW_vx[3].xy = blend weights (z is unused)$    float4x3 BW_vx@$$    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)$    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464)@$$    //vertex IDs and barycentric coords$    float2 vxID = float2 (floor(skewUV))@$    float3 barry = float3 (frac(skewUV), 0)@$    barry.z = 1.0-barry.x-barry.y@$$    BW_vx = ((barry.z>0) ? $        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :$        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)))@$$    //calculate derivatives to avoid triangular grid artifacts$    float2 dx = ddx(UV)@$    float2 dy = ddy(UV)@$$    //blend samples with calculated weights$    return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z)@;4;Create;2;True;tex;SAMPLER2D;0,0;In;;Float;False;True;UV;FLOAT2;0,0;In;;Float;False;tex2DStochastic;False;False;1;7;;False;2;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;822;2048,1808;Inherit;False;Constant;_Float0;Float 0;30;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1640;352,384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1646;1360,2848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;750;2048,1712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1410;1520,2544;Float;False;    //triangle vertices and blend weights$    //BW_vx[0...2].xyz = triangle verts$    //BW_vx[3].xy = blend weights (z is unused)$    float4x3 BW_vx@$$    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)$    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464)@$$    //vertex IDs and barycentric coords$    float2 vxID = float2 (floor(skewUV))@$    float3 barry = float3 (frac(skewUV), 0)@$    barry.z = 1.0-barry.x-barry.y@$$    BW_vx = ((barry.z>0) ? $        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :$        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)))@$$    //calculate derivatives to avoid triangular grid artifacts$    float2 dx = ddx(UV)@$    float2 dy = ddy(UV)@$$    //blend samples with calculated weights$    return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z)@;4;Create;2;True;tex;SAMPLER2D;0,0;In;;Float;False;True;UV;FLOAT2;0,0;In;;Float;False;tex2DStochastic;False;False;1;7;;False;2;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;55;272,592;Inherit;False;Property;_EdgePower;Edge Intensity;23;0;Create;False;0;0;0;False;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1641;496,384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1666;2400,752;Inherit;False;Property;_TessValue;TessValue;43;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1671;464,672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1698;2672,1040;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;864;2096,2576;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PosVertexDataNode;1677;2448,992;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;642;608,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1189;592,-64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1411;1664,2544;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;547;1504,2848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;865;2128,2704;Half;False;return float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + float3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0@;3;Create;0;Ambient;False;False;0;;False;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;623;2096,2384;Inherit;False;Property;_WaterColor;WaterColor;2;1;[Header];Fetch;True;1;MAIN OPTIONS;0;0;False;0;False;0,0.1607843,0.1568628,0;0,0.1698112,0.1661197,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;850;2160,2304;Inherit;False;Constant;_Float7;Float 7;30;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;569;1664,2320;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;751;2176,1712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1667;2448,832;Inherit;False;Property;_TessMin;Tess Min Distance;44;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1675;2832,992;Inherit;False;return UnityCalcDistanceTessFactor(vertex, minDist, maxDist, tess)@;1;Create;4;True;vertex;FLOAT4;0,0,0,0;In;;Inherit;False;True;minDist;FLOAT;0;In;;Inherit;False;True;maxDist;FLOAT;0;In;;Inherit;False;True;tess;FLOAT;1;In;;Inherit;False;Tess Distance;False;False;0;;False;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1180;768,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1687;3056,1024;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;424;2320,1712;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;656,384;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;832;2288,2848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;1824,2320;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1486;672,288;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$_CameraDepthTexture.GetDimensions(width, width)@$#endif;1;Call;1;True;width;FLOAT;17;InOut;;Inherit;False;DepthCheck;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;17;False;2;FLOAT;0;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;849;2336,2384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1427;2256,2640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1257;2448,1712;Inherit;False;NoiseVertOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;550;1968,2320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;591;2384,2512;Inherit;False;Property;_CausticIntensity;Caustic Intensity;28;0;Create;True;0;0;0;False;0;False;1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;655;896,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;827;1280,-464;Inherit;False;940.7345;515.6964;;9;43;889;894;904;903;888;891;890;1331;Main Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.ConditionalIfNode;1483;880,336;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;16;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1683;3200,992;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;869;2480,2384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;588;2672,2320;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;10,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;673;1040,-384;Inherit;False;GeneralFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1518;2672,2448;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$_CameraDepthTexture.GetDimensions(width, width)@$#endif;1;Call;1;True;width;FLOAT;17;InOut;;Inherit;False;DepthCheck;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;17;False;2;FLOAT;0;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;1637;1056,336;Inherit;False;EdgeFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1258;5104,1504;Inherit;False;1257;NoiseVertOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1212;4992,1728;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1213;4992,1856;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;890;1312,-144;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1678;3376,992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1519;2928,2320;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;16;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CrossProductOpNode;1210;5168,1792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;674;2048,144;Inherit;False;673;GeneralFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1249;5312,1536;Inherit;False;Property;_GerstnerWavesToggle;Gerstner Waves Toggle;36;0;Create;True;0;0;0;False;1;Header(Gerstner Waves (replaces Wave settings above));False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;903;1536,-240;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1688;3520,992;Inherit;False;TessellationDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;891;1472,-144;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;975;2096,640;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1638;2048,224;Inherit;False;1637;EdgeFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1689;6640,1600;Inherit;False;1688;TessellationDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1331;1744,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;888;1664,-144;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1209;5328,1792;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;1251;5168,1888;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;621;3120,2320;Inherit;False;Caustics;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1276;6432,1536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;714;2336,272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;1680,-416;Inherit;False;Property;_WaterColor;WaterColor;2;2;[HideInInspector];[Header];Create;True;1;MAIN OPTIONS;0;0;False;0;False;0,0.1607843,0.1568628,0;0,0.1698112,0.1661197,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;976;2256,640;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;1326;2112,768;Inherit;False;Property;_NormalMapDepthinfluence;Normal Map Depth influence;5;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1679;6880,1536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;622;2064,64;Inherit;False;621;Caustics;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1254;5472,1760;Inherit;False;Property;_GerstnerWaves;Gerstner Waves;36;0;Create;True;0;0;0;False;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Reference;1249;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;373;2464,272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;904;1872,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1330;2384,656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;889;1888,-336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1260;7008,1536;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;377;2608,272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;2480,352;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;0;False;0;False;0.94;0.925;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;549;2336,128;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;894;2032,-384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;696;672,2992;Inherit;False;1607;288;Normal Map Influence (only for non depth reconstructed world pos UVs);15;688;692;693;679;683;695;681;678;691;689;677;684;687;685;1647;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;978;2592,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1262;5744,1760;Inherit;False;FinalVertexNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1423;144,1792;Inherit;False;SecondaryNormalSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;678;1984,3056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;687;736,3152;Inherit;False;Property;_NormalInfluence;Normal Influence;31;0;Create;True;0;0;0;False;0;False;0.73;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;369;2720,432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;2896,48;Inherit;False;Property;_ShaderOptimizerEnabled;PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER;0;0;Create;False;0;0;0;True;1;ShaderOptimizerLockButton;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;677;1520,3152;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;2720,160;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;352;2880,-32;Inherit;False;Property;_NormalScaleSecondaryAnimated;Normal Scale Secondary Animated;48;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;2752,272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1261;2640,528;Inherit;False;1260;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1198;2928,-224;Inherit;False;Property;_CullMode;Cull Mode;3;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;3200,304;Inherit;False;Property;_UVTiling;UV Tiling;7;0;Create;True;0;0;0;True;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;2512,112;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;693;1792,3056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;1665;2672,816;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StickyNoteNode;1130;2944,560;Inherit;False;185;231;Vertex Offset;;1,1,1,1;Tested Vertex Offset via Normal Maps but the texture compression on any Normal map was too janky to implement it, hence why we are using math generated noise which is as smooth as it gets;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;694;1648,2768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1422;144,1712;Inherit;False;SecondaryNormalVector;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;684;1184,3056;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;689;1184,3152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;695;1360,3152;Inherit;False;Constant;_Float6;Float 6;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;681;1824,3152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;679;2112,3056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1367;-2816,2496;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;353;2896,-128;Inherit;False;Property;_NormalScaleAnimated;Normal Scale Animated;47;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1263;2640,608;Inherit;False;1262;FinalVertexNormals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;688;800,3056;Inherit;False;Property;_NormalSharpening;Normal Sharpening;30;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;691;1360,3056;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1583;-2624,2496;Inherit;False;DepthMaskedRefraction;-1;;172;c805f061214177c42bca056464193f81;2,40,0,103,0;2;35;FLOAT3;0,0,0;False;37;FLOAT;0.02;False;1;FLOAT2;38
Node;AmplifyShaderEditor.DotProductOpNode;692;1520,3056;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1647;1696,3152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;683;1008,3056;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;685;1024,3152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1197;2928,128;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;Moriohs Shaders/Enviroment Shaders/Sea-Water;False;False;False;False;False;False;True;True;True;False;True;False;False;False;False;False;False;False;True;True;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;51;True;Transparent;;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;7;5000;7500;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;1;PreviewType=Plane;False;0;0;True;1198;-1;0;False;-1;7;Custom;SamplerState sampler_CameraDepthTexture@;False;;Custom;Custom;#ifndef SHADER_TARGET_SURFACE_ANALYSIS;False;;Custom;Custom;Texture2D _CameraDepthTexture@;False;;Custom;Custom;#else //Do not remove comment, itll break the shader1;False;;Custom;Custom;UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture)@;False;;Custom;Custom;#endif //Do not remove comment, itll break the shader1;False;;Custom;Custom;uniform float4 _CameraDepthTexture_TexelSize@;False;;Custom;0;0;False;0;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1284;0;1275;2
WireConnection;1281;0;1208;3
WireConnection;1281;1;1285;0
WireConnection;1280;0;1207;3
WireConnection;1280;1;1285;0
WireConnection;1279;0;1206;3
WireConnection;1279;1;1285;0
WireConnection;1283;0;1208;1
WireConnection;1283;1;1208;2
WireConnection;1283;2;1281;0
WireConnection;1283;3;1208;4
WireConnection;1282;0;1207;1
WireConnection;1282;1;1207;2
WireConnection;1282;2;1280;0
WireConnection;1282;3;1207;4
WireConnection;1278;0;1206;1
WireConnection;1278;1;1206;2
WireConnection;1278;2;1279;0
WireConnection;1278;3;1206;4
WireConnection;1243;0;1242;0
WireConnection;1243;1;1244;0
WireConnection;1623;68;1624;0
WireConnection;1201;0;1283;0
WireConnection;1201;1;1205;0
WireConnection;1201;2;1202;0
WireConnection;1201;3;1203;0
WireConnection;1201;4;1228;0
WireConnection;1201;5;1243;0
WireConnection;1200;0;1282;0
WireConnection;1200;1;1205;0
WireConnection;1200;2;1202;0
WireConnection;1200;3;1203;0
WireConnection;1200;4;1228;0
WireConnection;1200;5;1243;0
WireConnection;625;0;1623;83
WireConnection;1000;0;998;1
WireConnection;1000;1;998;2
WireConnection;1199;0;1278;0
WireConnection;1199;1;1205;0
WireConnection;1199;2;1202;0
WireConnection;1199;3;1203;0
WireConnection;1199;4;1228;0
WireConnection;1199;5;1243;0
WireConnection;1625;0;1626;1
WireConnection;1625;1;1626;3
WireConnection;1211;0;1199;0
WireConnection;1211;1;1200;0
WireConnection;1211;2;1201;0
WireConnection;999;0;1000;0
WireConnection;999;1;1625;0
WireConnection;1001;0;998;3
WireConnection;1001;1;998;4
WireConnection;1627;0;416;0
WireConnection;1515;1;1514;0
WireConnection;1510;0;1515;3
WireConnection;1003;0;999;0
WireConnection;1003;1;1001;0
WireConnection;441;0;626;0
WireConnection;1259;0;1211;0
WireConnection;1513;23;1514;0
WireConnection;415;0;1627;0
WireConnection;1509;1;1515;3
WireConnection;1509;0;1510;0
WireConnection;1512;0;1513;0
WireConnection;80;0;1623;0
WireConnection;746;0;1003;0
WireConnection;746;2;743;0
WireConnection;746;1;415;0
WireConnection;412;0;1003;0
WireConnection;412;2;441;0
WireConnection;412;1;415;0
WireConnection;1508;0;1512;0
WireConnection;1508;1;1512;1
WireConnection;1508;2;1509;0
WireConnection;1271;0;1264;0
WireConnection;411;0;412;0
WireConnection;411;1;438;0
WireConnection;747;0;746;0
WireConnection;747;1;438;0
WireConnection;1246;0;1264;0
WireConnection;1246;1;1248;0
WireConnection;1507;0;1508;0
WireConnection;928;0;411;0
WireConnection;928;1;747;0
WireConnection;1273;0;1271;1
WireConnection;1269;0;1273;0
WireConnection;1269;1;1246;0
WireConnection;1506;0;1507;0
WireConnection;1274;0;928;0
WireConnection;1504;0;1505;0
WireConnection;1504;1;1506;0
WireConnection;1255;1;1274;0
WireConnection;1255;0;1269;0
WireConnection;1502;0;1504;0
WireConnection;1503;0;1504;0
WireConnection;934;0;1255;0
WireConnection;1634;1;1447;0
WireConnection;1636;0;370;0
WireConnection;1630;0;1634;3
WireConnection;1630;1;1628;0
WireConnection;1501;0;1503;0
WireConnection;1501;1;1502;0
WireConnection;633;0;1623;87
WireConnection;1617;0;1618;1
WireConnection;1617;1;1618;3
WireConnection;1619;0;87;0
WireConnection;1500;0;1501;0
WireConnection;1256;1;935;0
WireConnection;1631;0;1630;0
WireConnection;1631;1;1636;0
WireConnection;940;0;1256;0
WireConnection;940;1;941;0
WireConnection;1458;0;1430;2
WireConnection;1458;2;1631;0
WireConnection;1458;3;1477;0
WireConnection;1458;4;1477;0
WireConnection;344;0;346;0
WireConnection;1498;0;1500;0
WireConnection;1620;0;1619;0
WireConnection;1620;1;1617;0
WireConnection;1620;2;1622;0
WireConnection;628;0;1426;0
WireConnection;628;1;629;0
WireConnection;671;0;1458;0
WireConnection;1621;0;1620;0
WireConnection;1621;1;1619;1
WireConnection;923;0;344;0
WireConnection;923;1;631;0
WireConnection;1497;0;1499;0
WireConnection;1497;1;1498;0
WireConnection;939;0;940;0
WireConnection;468;0;427;0
WireConnection;468;1;469;0
WireConnection;924;0;1621;0
WireConnection;924;1;923;0
WireConnection;924;2;939;0
WireConnection;1391;0;628;0
WireConnection;1399;0;1420;0
WireConnection;1399;1;1400;0
WireConnection;1376;0;1497;0
WireConnection;600;0;1425;0
WireConnection;540;0;411;0
WireConnection;540;1;468;0
WireConnection;1655;0;928;0
WireConnection;1674;0;1673;0
WireConnection;340;0;87;0
WireConnection;340;1;924;0
WireConnection;1397;0;1399;0
WireConnection;1397;1;1376;0
WireConnection;1179;0;648;0
WireConnection;1179;1;1175;0
WireConnection;1648;0;1639;0
WireConnection;1648;1;52;0
WireConnection;748;0;747;0
WireConnection;748;1;468;0
WireConnection;1318;0;601;0
WireConnection;1419;0;1391;0
WireConnection;1419;1;600;0
WireConnection;488;0;479;0
WireConnection;488;1;489;0
WireConnection;1407;0;1391;0
WireConnection;1407;1;1425;0
WireConnection;1649;0;1648;0
WireConnection;372;0;340;0
WireConnection;1616;1;1179;0
WireConnection;1616;0;1175;0
WireConnection;1670;0;1674;1
WireConnection;668;0;646;0
WireConnection;1388;0;1397;0
WireConnection;1388;1;1407;0
WireConnection;1388;2;1420;1
WireConnection;749;0;748;0
WireConnection;749;1;488;0
WireConnection;1415;0;1397;0
WireConnection;1415;1;1419;0
WireConnection;1415;2;1420;1
WireConnection;484;0;540;0
WireConnection;484;1;488;0
WireConnection;1333;0;1319;0
WireConnection;1333;1;1318;0
WireConnection;1672;1;1656;0
WireConnection;1672;0;1670;0
WireConnection;1190;0;1181;0
WireConnection;1190;1;1191;0
WireConnection;666;0;1616;0
WireConnection;666;1;667;0
WireConnection;666;2;646;0
WireConnection;675;0;667;0
WireConnection;675;1;668;0
WireConnection;568;0;570;0
WireConnection;568;1;1388;0
WireConnection;1640;0;372;1
WireConnection;1640;1;1649;0
WireConnection;1646;0;1333;0
WireConnection;750;0;484;0
WireConnection;750;1;749;0
WireConnection;1410;0;570;0
WireConnection;1410;1;1415;0
WireConnection;1641;0;1640;0
WireConnection;1671;0;1672;0
WireConnection;1698;0;1668;0
WireConnection;1698;1;1700;0
WireConnection;642;0;666;0
WireConnection;642;1;675;0
WireConnection;1189;0;1190;0
WireConnection;1411;0;1410;0
WireConnection;547;0;1646;0
WireConnection;569;0;568;0
WireConnection;751;0;750;0
WireConnection;751;1;822;0
WireConnection;1675;0;1677;0
WireConnection;1675;1;1667;0
WireConnection;1675;2;1698;0
WireConnection;1675;3;1666;0
WireConnection;1180;0;642;0
WireConnection;1180;1;1189;0
WireConnection;1687;0;1666;0
WireConnection;424;1;751;0
WireConnection;54;0;1641;0
WireConnection;54;1;55;0
WireConnection;54;2;1671;0
WireConnection;832;0;547;0
WireConnection;548;0;569;1
WireConnection;548;1;1411;1
WireConnection;548;2;547;0
WireConnection;849;0;623;0
WireConnection;849;1;850;0
WireConnection;1427;0;864;1
WireConnection;1427;1;865;0
WireConnection;1257;0;424;0
WireConnection;550;0;548;0
WireConnection;655;0;1180;0
WireConnection;1483;0;1486;2
WireConnection;1483;2;54;0
WireConnection;1683;0;1675;0
WireConnection;1683;1;1687;0
WireConnection;869;0;849;0
WireConnection;869;1;1427;0
WireConnection;869;2;832;0
WireConnection;588;0;550;0
WireConnection;588;1;869;0
WireConnection;588;2;591;0
WireConnection;673;0;655;0
WireConnection;1637;0;1483;0
WireConnection;1212;0;1199;3
WireConnection;1212;1;1200;3
WireConnection;1212;2;1201;3
WireConnection;1213;0;1199;4
WireConnection;1213;1;1200;4
WireConnection;1213;2;1201;4
WireConnection;1678;0;1683;0
WireConnection;1519;0;1518;2
WireConnection;1519;2;588;0
WireConnection;1210;0;1213;0
WireConnection;1210;1;1212;0
WireConnection;1249;1;1258;0
WireConnection;1249;0;1259;0
WireConnection;1688;0;1678;0
WireConnection;891;0;890;0
WireConnection;1331;0;903;0
WireConnection;888;0;891;0
WireConnection;1209;0;1210;0
WireConnection;621;0;1519;0
WireConnection;1276;0;1249;0
WireConnection;1276;1;1275;2
WireConnection;714;0;1638;0
WireConnection;714;1;674;0
WireConnection;976;0;975;0
WireConnection;1679;0;1276;0
WireConnection;1679;1;1689;0
WireConnection;1254;1;1251;0
WireConnection;1254;0;1209;0
WireConnection;373;0;714;0
WireConnection;904;0;1331;0
WireConnection;1330;0;976;1
WireConnection;1330;1;1326;0
WireConnection;889;0;43;0
WireConnection;889;1;888;0
WireConnection;1260;0;1679;0
WireConnection;377;0;373;0
WireConnection;549;0;622;0
WireConnection;549;1;674;0
WireConnection;549;2;1638;0
WireConnection;894;0;43;0
WireConnection;894;1;889;0
WireConnection;894;2;904;0
WireConnection;978;0;671;0
WireConnection;978;1;1330;0
WireConnection;1262;0;1254;0
WireConnection;1423;0;1623;97
WireConnection;678;0;693;0
WireConnection;678;1;681;0
WireConnection;369;0;978;0
WireConnection;374;0;377;0
WireConnection;374;1;39;0
WireConnection;288;0;894;0
WireConnection;288;1;549;0
WireConnection;693;0;692;0
WireConnection;1665;0;1666;0
WireConnection;1665;1;1667;0
WireConnection;1665;2;1668;0
WireConnection;694;0;547;0
WireConnection;694;1;679;0
WireConnection;1422;0;1623;98
WireConnection;684;0;683;0
WireConnection;684;1;688;0
WireConnection;689;0;685;0
WireConnection;689;1;688;0
WireConnection;681;0;1647;0
WireConnection;679;0;678;0
WireConnection;691;0;684;0
WireConnection;691;1;689;0
WireConnection;1583;35;1367;0
WireConnection;692;0;691;0
WireConnection;692;1;695;0
WireConnection;1647;0;677;0
WireConnection;685;0;687;0
WireConnection;1197;0;288;0
WireConnection;1197;1;81;0
WireConnection;1197;4;374;0
WireConnection;1197;9;369;0
WireConnection;1197;11;1261;0
WireConnection;1197;12;1263;0
WireConnection;1197;14;1665;0
ASEEND*/
//CHKSM=1E22ADA3EA44080BEE8299E3F89DE90018111A3A