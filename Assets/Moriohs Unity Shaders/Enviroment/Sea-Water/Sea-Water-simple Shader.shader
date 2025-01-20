// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Moriohs Shaders/Enviroment Shaders/Sea-Water-simple"
{
	Properties
	{
		[ShaderOptimizerLockButton]_ShaderOptimizerEnabled("PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER", Float) = 0
		[Header(MAIN OPTIONS)]_WaterColor("WaterColor", Color) = (0,0.1607843,0.1568628,0)
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 2
		_WaterDepth("Water Depth", Range( 0 , 1)) = 0.975
		_NormalMapDepthinfluence("Normal Map Depth influence", Range( 0 , 1)) = 0.2
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.94
		_UVTiling("UV Tiling", Float) = 0.01
		_GeneralFoamAmount("General Foam Amount", Range( 0 , 1)) = 0.645
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
		[HideInInspector][ToggleUI]_NormalScaleAnimated("Normal Scale Animated", Int) = 1
		[HideInInspector][ToggleUI]_NormalScaleSecondaryAnimated("Normal Scale Secondary Animated", Int) = 1

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="False" }
	LOD 0

		Cull [_CullMode]
		AlphaToMask Off
		ZWrite Off
		ZTest LEqual
		ColorMask RGBA
		
		Blend SrcAlpha OneMinusSrcAlpha
		

		CGINCLUDE
		#pragma target 5.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDCG

		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" }
			
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
			#define _ALPHABLEND_ON 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _GLOSSYREFLECTIONS_OFF

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#ifndef UNITY_PASS_FORWARDBASE
				#define UNITY_PASS_FORWARDBASE
			#endif
			#include "HLSLSupport.cginc"
			#ifndef UNITY_INSTANCED_LOD_FADE
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#ifndef UNITY_INSTANCED_SH
				#define UNITY_INSTANCED_SH
			#endif
			#ifndef UNITY_INSTANCED_LIGHTMAPSTS
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_VERT_POSITION
			SamplerState sampler_CameraDepthTexture;
			Texture2D _CameraDepthTexture;
			uniform float4 _CameraDepthTexture_TexelSize;

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				#if defined(LIGHTMAP_ON) || (!defined(LIGHTMAP_ON) && SHADER_TARGET >= 30)
					float4 lmap : TEXCOORD0;
				#endif
				#if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD1;
				#endif
				#if defined(UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS) && UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHTING_COORDS(2,3)
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_SHADOW_COORDS(2)
					#else
						SHADOW_COORDS(2)
					#endif
				#endif
				#ifdef ASE_FOG
					UNITY_FOG_COORDS(4)
				#endif
				float4 tSpace0 : TEXCOORD5;
				float4 tSpace1 : TEXCOORD6;
				float4 tSpace2 : TEXCOORD7;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform float _CullMode;
			uniform int _NormalScaleSecondaryAnimated;
			uniform int _NormalScaleAnimated;
			uniform float _ShaderOptimizerEnabled;
			uniform float4 _WaterColor;
			uniform sampler2D _Normal;
			uniform float _ScrollSpeed;
			uniform float2 _VectorXY;
			uniform float4 _Normal_ST;
			uniform float _UVTiling;
			uniform float _NormalScale;
			uniform sampler2D _SecondaryNormal;
			uniform float _SecondaryScrollSpeed;
			uniform float2 _SecondaryVectorXY;
			uniform float4 _SecondaryNormal_ST;
			uniform float _NormalScaleSecondary;
			uniform float _WaterDepth;
			uniform float _GeneralFoamStrength;
			uniform float _GeneralFoamAmount;
			uniform float _GeneralFoamDepthFalloff;
			uniform sampler2D _SeaFoam;
			uniform float4 _SeaFoam_ST;
			uniform float _EdgeFoamSpeed;
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
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = UnityObjectToViewPos(v.vertex.xyz);
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord9.x = eyeDepth;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				#ifdef DYNAMICLIGHTMAP_ON
				o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				#ifdef LIGHTMAP_ON
				o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						o.sh = 0;
						#ifdef VERTEXLIGHT_ON
						o.sh += Shade4PointLights (
							unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
							unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
							unity_4LightAtten0, worldPos, worldNormal);
						#endif
						o.sh = ShadeSHPerVertex (worldNormal, o.sh);
					#endif
				#endif

				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy);
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_TRANSFER_SHADOW(o, v.texcoord1.xy);
					#else
						TRANSFER_SHADOW(o);
					#endif
				#endif

				#ifdef ASE_FOG
					UNITY_TRANSFER_FOG(o,o.pos);
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(o.pos);
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif
			
			fixed4 frag (v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				) : SV_Target 
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif
				float3 WorldTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
				float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				#else
					half atten = 1;
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				sampler2D tex96_g112 = _Normal;
				float mulTime7_g112 = _Time.y * _ScrollSpeed;
				float temp_output_68_0_g112 = _UVTiling;
				float2 appendResult105_g112 = (float2(worldPos.x , worldPos.z));
				float2 temp_output_104_0_g112 = ( ( _Normal_ST.xy * temp_output_68_0_g112 * appendResult105_g112 ) + _Normal_ST.zw );
				float2 panner17_g112 = ( mulTime7_g112 * _VectorXY + temp_output_104_0_g112);
				float2 UV96_g112 = ( panner17_g112 + 0.25 );
				float _NormalScale96_g112 = _NormalScale;
				float3 localtex2DStochasticNormals96_g112 = tex2DStochasticNormals( tex96_g112 , UV96_g112 , _NormalScale96_g112 );
				sampler2D tex79_g112 = _Normal;
				float mulTime4_g112 = _Time.y * _ScrollSpeed;
				float2 panner12_g112 = ( ( mulTime4_g112 * 2.179 ) * _VectorXY + ( 1.0 - temp_output_104_0_g112 ));
				float2 UV79_g112 = ( 1.0 - panner12_g112 );
				float _NormalScale79_g112 = _NormalScale;
				float3 localtex2DStochasticNormals79_g112 = tex2DStochasticNormals( tex79_g112 , UV79_g112 , _NormalScale79_g112 );
				sampler2D tex76_g112 = _SecondaryNormal;
				float mulTime16_g112 = _Time.y * _SecondaryScrollSpeed;
				float2 panner21_g112 = ( mulTime16_g112 * _SecondaryVectorXY + ( ( _SecondaryNormal_ST.xy * temp_output_68_0_g112 * appendResult105_g112 ) + _SecondaryNormal_ST.zw ));
				float2 UV76_g112 = panner21_g112;
				float _NormalScale76_g112 = _NormalScaleSecondary;
				float3 localtex2DStochasticNormals76_g112 = tex2DStochasticNormals( tex76_g112 , UV76_g112 , _NormalScale76_g112 );
				float3 normalizeResult66_g112 = normalize( BlendNormals( BlendNormals( localtex2DStochasticNormals96_g112 , localtex2DStochasticNormals79_g112 ) , localtex2DStochasticNormals76_g112 ) );
				float3 Normals80 = normalizeResult66_g112;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal891 = Normals80;
				float3 worldNormal891 = normalize( float3(dot(tanToWorld0,tanNormal891), dot(tanToWorld1,tanNormal891), dot(tanToWorld2,tanNormal891)) );
				float fresnelNdotV888 = dot( worldNormal891, worldViewDir );
				float fresnelNode888 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV888, 5.0 ) );
				float localDepthCheck1211 = ( 0.0 );
				float width1211 = 17;
				{
				#ifndef SHADER_TARGET_SURFACE_ANALYSIS
				_CameraDepthTexture.GetDimensions(width1211, width1211);
				#endif
				}
				float localscreenDepth1217 = ( 0.0 );
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 SP1217 = ase_screenPosNorm;
				float ScreenDepth1217 = 0;
				{
				#ifndef SHADER_TARGET_SURFACE_ANALYSIS
				ScreenDepth1217 = LinearEyeDepth(_CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP1217.xy));
				#else
				ScreenDepth1217 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP1217.xy ));
				#endif
				}
				float eyeDepth = IN.ase_texcoord9.x;
				float ifLocalVar1210 = 0;
				if( width1211 <= 16.0 )
				ifLocalVar1210 = 1.0;
				else
				ifLocalVar1210 = ( ( ScreenDepth1217 - eyeDepth ) * ( 1.0 - _WaterDepth ) );
				float WaterDepth671 = ifLocalVar1210;
				float4 lerpResult894 = lerp( _WaterColor , ( _WaterColor * fresnelNode888 ) , saturate( ( WaterDepth671 * 0.5 ) ));
				float3 temp_cast_0 = (1.0).xxx;
				float dotResult1179 = dot( Normals80 , temp_cast_0 );
				float GeneralFoam673 = saturate( ( ( ( dotResult1179 * _GeneralFoamStrength * _GeneralFoamAmount ) - ( _GeneralFoamStrength * ( 1.0 - _GeneralFoamAmount ) ) ) * saturate( ( WaterDepth671 * _GeneralFoamDepthFalloff ) ) ) );
				float localDepthCheck1202 = ( 0.0 );
				float width1202 = 17;
				{
				_CameraDepthTexture.GetDimensions(width1202, width1202);
				}
				sampler2D tex340 = _SeaFoam;
				float2 appendResult1221 = (float2(worldPos.x , worldPos.z));
				float2 NormalVector625 = _VectorXY;
				float mulTime344 = _Time.y * _EdgeFoamSpeed;
				float2 UV340 = ( ( ( _SeaFoam_ST.xy * appendResult1221 * _UVTiling ) + _SeaFoam_ST.zw ) + ( NormalVector625 * mulTime344 ) );
				float4 localtex2DStochastic340 = tex2DStochastic( tex340 , UV340 );
				float ifLocalVar1203 = 0;
				if( width1202 > 16.0 )
				ifLocalVar1203 = ( saturate( ( localtex2DStochastic340.y - saturate( ( WaterDepth671 * _EdgeDistance ) ) ) ) * _EdgePower );
				
				o.Albedo = ( lerpResult894 + ( GeneralFoam673 + ifLocalVar1203 ) ).rgb;
				o.Normal = Normals80;
				o.Emission = half3( 0, 0, 0 );
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = 0;
				#endif
				o.Smoothness = ( saturate( ( 1.0 - ( ifLocalVar1203 + GeneralFoam673 ) ) ) * _Smoothness );
				o.Occlusion = 1;
				o.Alpha = saturate( ( WaterDepth671 + ( Normals80.y * _NormalMapDepthinfluence ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;				

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif

				fixed4 c = 0;
				float3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;

				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = worldPos;
				giInput.worldViewDir = worldViewDir;
				giInput.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = IN.lmap;
				#else
					giInput.lightmapUV = 0.0;
				#endif
				#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
					giInput.ambient = IN.sh;
				#else
					giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
					giInput.boxMin[0] = unity_SpecCube0_BoxMin;
				#endif
				#ifdef UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif
				
				#if defined(_SPECULAR_SETUP)
					LightingStandardSpecular_GI(o, giInput, gi);
				#else
					LightingStandard_GI( o, giInput, gi );
				#endif

				#ifdef ASE_BAKEDGI
					gi.indirect.diffuse = BakedGI;
				#endif

				#if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON) && defined(ASE_NO_AMBIENT)
					gi.indirect.diffuse = 0;
				#endif

				#if defined(_SPECULAR_SETUP)
					c += LightingStandardSpecular (o, worldViewDir, gi);
				#else
					c += LightingStandard( o, worldViewDir, gi );
				#endif
				
				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;
					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 transmission = max(0 , -dot(o.Normal, gi.light.dir)) * lightAtten * Transmission;
					c.rgb += o.Albedo * transmission;
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 lightDir = gi.light.dir + o.Normal * normal;
					half transVdotL = pow( saturate( dot( worldViewDir, -lightDir ) ), scattering );
					half3 translucency = lightAtten * (transVdotL * direct + gi.indirect.diffuse * ambient) * Translucency;
					c.rgb += o.Albedo * translucency * strength;
				}
				#endif

				//#ifdef _REFRACTION_ASE
				//	float4 projScreenPos = ScreenPos / ScreenPos.w;
				//	float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
				//	projScreenPos.xy += refractionOffset.xy;
				//	float3 refraction = UNITY_SAMPLE_SCREENSPACE_TEXTURE( _GrabTexture, projScreenPos ) * RefractionColor;
				//	color.rgb = lerp( refraction, color.rgb, color.a );
				//	color.a = 1;
				//#endif

				c.rgb += o.Emission;

				#ifdef ASE_FOG
					UNITY_APPLY_FOG(IN.fogCoord, c);
				#endif
				return c;
			}
			ENDCG
		}

		
		Pass
		{
			
			Name "ForwardAdd"
			Tags { "LightMode"="ForwardAdd" }
			ZWrite Off
			Blend SrcAlpha One

			CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
			#define _ALPHABLEND_ON 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _GLOSSYREFLECTIONS_OFF

			#pragma vertex vert
			#pragma fragment frag
			#pragma skip_variants INSTANCING_ON
			#pragma multi_compile_fwdadd_fullshadows
			#ifndef UNITY_PASS_FORWARDADD
				#define UNITY_PASS_FORWARDADD
			#endif
			#include "HLSLSupport.cginc"
			#if !defined( UNITY_INSTANCED_LOD_FADE )
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#if !defined( UNITY_INSTANCED_SH )
				#define UNITY_INSTANCED_SH
			#endif
			#if !defined( UNITY_INSTANCED_LIGHTMAPSTS )
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_VERT_POSITION
			SamplerState sampler_CameraDepthTexture;
			Texture2D _CameraDepthTexture;
			uniform float4 _CameraDepthTexture_TexelSize;

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHTING_COORDS(1,2)
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_SHADOW_COORDS(1)
					#else
						SHADOW_COORDS(1)
					#endif
				#endif
				#ifdef ASE_FOG
					UNITY_FOG_COORDS(3)
				#endif
				float4 tSpace0 : TEXCOORD5;
				float4 tSpace1 : TEXCOORD6;
				float4 tSpace2 : TEXCOORD7;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform float _CullMode;
			uniform int _NormalScaleSecondaryAnimated;
			uniform int _NormalScaleAnimated;
			uniform float _ShaderOptimizerEnabled;
			uniform float4 _WaterColor;
			uniform sampler2D _Normal;
			uniform float _ScrollSpeed;
			uniform float2 _VectorXY;
			uniform float4 _Normal_ST;
			uniform float _UVTiling;
			uniform float _NormalScale;
			uniform sampler2D _SecondaryNormal;
			uniform float _SecondaryScrollSpeed;
			uniform float2 _SecondaryVectorXY;
			uniform float4 _SecondaryNormal_ST;
			uniform float _NormalScaleSecondary;
			uniform float _WaterDepth;
			uniform float _GeneralFoamStrength;
			uniform float _GeneralFoamAmount;
			uniform float _GeneralFoamDepthFalloff;
			uniform sampler2D _SeaFoam;
			uniform float4 _SeaFoam_ST;
			uniform float _EdgeFoamSpeed;
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
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 objectToViewPos = UnityObjectToViewPos(v.vertex.xyz);
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord9.x = eyeDepth;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy);
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_TRANSFER_SHADOW(o, v.texcoord1.xy);
					#else
						TRANSFER_SHADOW(o);
					#endif
				#endif

				#ifdef ASE_FOG
					UNITY_TRANSFER_FOG(o,o.pos);
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(o.pos);
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			fixed4 frag ( v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				) : SV_Target 
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif
				float3 WorldTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
				float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				#else
					half atten = 1;
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif


				sampler2D tex96_g112 = _Normal;
				float mulTime7_g112 = _Time.y * _ScrollSpeed;
				float temp_output_68_0_g112 = _UVTiling;
				float2 appendResult105_g112 = (float2(worldPos.x , worldPos.z));
				float2 temp_output_104_0_g112 = ( ( _Normal_ST.xy * temp_output_68_0_g112 * appendResult105_g112 ) + _Normal_ST.zw );
				float2 panner17_g112 = ( mulTime7_g112 * _VectorXY + temp_output_104_0_g112);
				float2 UV96_g112 = ( panner17_g112 + 0.25 );
				float _NormalScale96_g112 = _NormalScale;
				float3 localtex2DStochasticNormals96_g112 = tex2DStochasticNormals( tex96_g112 , UV96_g112 , _NormalScale96_g112 );
				sampler2D tex79_g112 = _Normal;
				float mulTime4_g112 = _Time.y * _ScrollSpeed;
				float2 panner12_g112 = ( ( mulTime4_g112 * 2.179 ) * _VectorXY + ( 1.0 - temp_output_104_0_g112 ));
				float2 UV79_g112 = ( 1.0 - panner12_g112 );
				float _NormalScale79_g112 = _NormalScale;
				float3 localtex2DStochasticNormals79_g112 = tex2DStochasticNormals( tex79_g112 , UV79_g112 , _NormalScale79_g112 );
				sampler2D tex76_g112 = _SecondaryNormal;
				float mulTime16_g112 = _Time.y * _SecondaryScrollSpeed;
				float2 panner21_g112 = ( mulTime16_g112 * _SecondaryVectorXY + ( ( _SecondaryNormal_ST.xy * temp_output_68_0_g112 * appendResult105_g112 ) + _SecondaryNormal_ST.zw ));
				float2 UV76_g112 = panner21_g112;
				float _NormalScale76_g112 = _NormalScaleSecondary;
				float3 localtex2DStochasticNormals76_g112 = tex2DStochasticNormals( tex76_g112 , UV76_g112 , _NormalScale76_g112 );
				float3 normalizeResult66_g112 = normalize( BlendNormals( BlendNormals( localtex2DStochasticNormals96_g112 , localtex2DStochasticNormals79_g112 ) , localtex2DStochasticNormals76_g112 ) );
				float3 Normals80 = normalizeResult66_g112;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal891 = Normals80;
				float3 worldNormal891 = normalize( float3(dot(tanToWorld0,tanNormal891), dot(tanToWorld1,tanNormal891), dot(tanToWorld2,tanNormal891)) );
				float fresnelNdotV888 = dot( worldNormal891, worldViewDir );
				float fresnelNode888 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV888, 5.0 ) );
				float localDepthCheck1211 = ( 0.0 );
				float width1211 = 17;
				{
				#ifndef SHADER_TARGET_SURFACE_ANALYSIS
				_CameraDepthTexture.GetDimensions(width1211, width1211);
				#endif
				}
				float localscreenDepth1217 = ( 0.0 );
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 SP1217 = ase_screenPosNorm;
				float ScreenDepth1217 = 0;
				{
				#ifndef SHADER_TARGET_SURFACE_ANALYSIS
				ScreenDepth1217 = LinearEyeDepth(_CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP1217.xy));
				#else
				ScreenDepth1217 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP1217.xy ));
				#endif
				}
				float eyeDepth = IN.ase_texcoord9.x;
				float ifLocalVar1210 = 0;
				if( width1211 <= 16.0 )
				ifLocalVar1210 = 1.0;
				else
				ifLocalVar1210 = ( ( ScreenDepth1217 - eyeDepth ) * ( 1.0 - _WaterDepth ) );
				float WaterDepth671 = ifLocalVar1210;
				float4 lerpResult894 = lerp( _WaterColor , ( _WaterColor * fresnelNode888 ) , saturate( ( WaterDepth671 * 0.5 ) ));
				float3 temp_cast_0 = (1.0).xxx;
				float dotResult1179 = dot( Normals80 , temp_cast_0 );
				float GeneralFoam673 = saturate( ( ( ( dotResult1179 * _GeneralFoamStrength * _GeneralFoamAmount ) - ( _GeneralFoamStrength * ( 1.0 - _GeneralFoamAmount ) ) ) * saturate( ( WaterDepth671 * _GeneralFoamDepthFalloff ) ) ) );
				float localDepthCheck1202 = ( 0.0 );
				float width1202 = 17;
				{
				_CameraDepthTexture.GetDimensions(width1202, width1202);
				}
				sampler2D tex340 = _SeaFoam;
				float2 appendResult1221 = (float2(worldPos.x , worldPos.z));
				float2 NormalVector625 = _VectorXY;
				float mulTime344 = _Time.y * _EdgeFoamSpeed;
				float2 UV340 = ( ( ( _SeaFoam_ST.xy * appendResult1221 * _UVTiling ) + _SeaFoam_ST.zw ) + ( NormalVector625 * mulTime344 ) );
				float4 localtex2DStochastic340 = tex2DStochastic( tex340 , UV340 );
				float ifLocalVar1203 = 0;
				if( width1202 > 16.0 )
				ifLocalVar1203 = ( saturate( ( localtex2DStochastic340.y - saturate( ( WaterDepth671 * _EdgeDistance ) ) ) ) * _EdgePower );
				
				o.Albedo = ( lerpResult894 + ( GeneralFoam673 + ifLocalVar1203 ) ).rgb;
				o.Normal = Normals80;
				o.Emission = half3( 0, 0, 0 );
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = 0;
				#endif
				o.Smoothness = ( saturate( ( 1.0 - ( ifLocalVar1203 + GeneralFoam673 ) ) ) * _Smoothness );
				o.Occlusion = 1;
				o.Alpha = saturate( ( WaterDepth671 + ( Normals80.y * _NormalMapDepthinfluence ) ) );
				float AlphaClipThreshold = 0.5;
				float3 Transmission = 1;
				float3 Translucency = 1;		

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif

				fixed4 c = 0;
				float3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;
				gi.light.color *= atten;

				#if defined(_SPECULAR_SETUP)
					c += LightingStandardSpecular( o, worldViewDir, gi );
				#else
					c += LightingStandard( o, worldViewDir, gi );
				#endif
				
				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;
					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 transmission = max(0 , -dot(o.Normal, gi.light.dir)) * lightAtten * Transmission;
					c.rgb += o.Albedo * transmission;
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 lightDir = gi.light.dir + o.Normal * normal;
					half transVdotL = pow( saturate( dot( worldViewDir, -lightDir ) ), scattering );
					half3 translucency = lightAtten * (transVdotL * direct + gi.indirect.diffuse * ambient) * Translucency;
					c.rgb += o.Albedo * translucency * strength;
				}
				#endif

				//#ifdef _REFRACTION_ASE
				//	float4 projScreenPos = ScreenPos / ScreenPos.w;
				//	float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
				//	projScreenPos.xy += refractionOffset.xy;
				//	float3 refraction = UNITY_SAMPLE_SCREENSPACE_TEXTURE( _GrabTexture, projScreenPos ) * RefractionColor;
				//	color.rgb = lerp( refraction, color.rgb, color.a );
				//	color.a = 1;
				//#endif

				#ifdef ASE_FOG
					UNITY_APPLY_FOG(IN.fogCoord, c);
				#endif
				return c;
			}
			ENDCG
		}

	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
21;29;2106;954;-1546.109;381.2163;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;11;-1424,880;Inherit;False;327.2458;240.3555;;1;383;UV Tiling;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;82;-320,896;Inherit;False;628.8539;354.6828;;3;80;625;1128;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-1328,960;Inherit;False;Property;_UVTiling;UV Tiling;6;0;Create;True;0;0;0;False;0;False;0.01;1500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-1479.034,256;Inherit;False;2475.49;586.1514;;27;52;1203;54;1202;55;1209;1208;1207;1206;372;340;924;344;923;346;631;87;1220;1221;1222;1223;1224;1225;1226;1227;1228;1229;EdgeFoam;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;87;-1456,304;Inherit;True;Property;_SeaFoam;SeaFoam;20;0;Create;True;0;0;0;False;2;Space(25);Header(EDGE FOAM);False;0066da7fc33808048a085ab52a41c20a;0066da7fc33808048a085ab52a41c20a;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldPosInputsNode;1220;-1232,464;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;1128;-208,960;Inherit;False;Normal scroll;10;;112;8e7734c034edf454cad15a4da30f1093;0;1;68;FLOAT;0;False;5;FLOAT3;0;FLOAT2;83;FLOAT;87;FLOAT2;98;FLOAT;97
Node;AmplifyShaderEditor.DynamicAppendNode;1221;-1056,496;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;625;112,1040;Inherit;False;NormalVector;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;346;-960,720;Inherit;False;Property;_EdgeFoamSpeed;Edge Foam Speed;21;0;Create;True;1;EDGE FOAM;0;0;False;0;False;0.025;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;1222;-1232,368;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.ScreenPosInputsNode;1218;1456,512;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;631;-784,640;Inherit;False;625;NormalVector;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1223;-896,496;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;344;-768,720;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1219;1568,688;Inherit;False;Property;_WaterDepth;Water Depth;3;0;Create;True;0;0;0;True;0;False;0.975;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1224;-752,496;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;1217;1664,496;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$ScreenDepth = LinearEyeDepth(_CameraDepthTexture.Sample(sampler_CameraDepthTexture, SP.xy))@$#else$ScreenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, SP.xy ))@$#endif;1;Call;2;True;SP;FLOAT4;0,0,0,0;In;;Inherit;False;True;ScreenDepth;FLOAT;0;Out;;Inherit;False;screenDepth;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.SurfaceDepthNode;1216;1632,608;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;923;-480,560;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;1215;1856,688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;924;-336,496;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1214;1904,560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;340;-288,304;Float;False;    //triangle vertices and blend weights$    //BW_vx[0...2].xyz = triangle verts$    //BW_vx[3].xy = blend weights (z is unused)$    float4x3 BW_vx@$$    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)$    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464)@$$    //vertex IDs and barycentric coords$    float2 vxID = float2 (floor(skewUV))@$    float3 barry = float3 (frac(skewUV), 0)@$    barry.z = 1.0-barry.x-barry.y@$$    BW_vx = ((barry.z>0) ? $        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :$        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)))@$$    //calculate derivatives to avoid triangular grid artifacts$    float2 dx = ddx(UV)@$    float2 dy = ddy(UV)@$$    //blend samples with calculated weights$    return mul(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + $            mul(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z)@;4;Create;2;True;tex;SAMPLER2D;0,0;In;;Float;False;True;UV;FLOAT2;0,0;In;;Float;False;tex2DStochastic;False;False;1;7;;False;2;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1212;2048,656;Inherit;False;Constant;_Float9;Float 9;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1213;2048,560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1211;2000,448;Inherit;False;#ifndef SHADER_TARGET_SURFACE_ANALYSIS$_CameraDepthTexture.GetDimensions(width, width)@$#endif;1;Call;1;True;width;FLOAT;17;InOut;;Inherit;False;DepthCheck;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;17;False;2;FLOAT;0;FLOAT;2
Node;AmplifyShaderEditor.ConditionalIfNode;1210;2208,512;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;16;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;112,960;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;372;-144,304;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;670;-32,-464;Inherit;False;1271.053;579.251;;16;1181;1191;1189;1190;675;668;646;667;673;655;1180;642;666;1179;648;1192;General Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1192;160,-304;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;648;144,-384;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1206;-16,368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;646;32,-144;Inherit;False;Property;_GeneralFoamAmount;General Foam Amount;7;0;Create;True;0;0;0;False;0;False;0.645;0.475;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;671;2384,512;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1179;320,-384;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;668;288,-144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;667;32,-224;Inherit;False;Property;_GeneralFoamStrength;General Foam Strength;8;0;Create;True;0;0;0;False;0;False;1.65;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-304,592;Inherit;False;Property;_EdgeDistance;Edge Distance;23;0;Create;True;0;0;0;True;0;False;0.7;18;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1227;-176,464;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1181;288,-64;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1191;192,16;Inherit;False;Property;_GeneralFoamDepthFalloff;General Foam Depth Falloff;9;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1207;-16,368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1190;464,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;675;448,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;448,-384;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1208;-16,432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1226;16,464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1189;592,-64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1209;-16,432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1225;144,464;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;642;608,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1180;768,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1228;320,400;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1229;464,400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;320,496;Inherit;False;Property;_EdgePower;Edge Intensity;22;0;Create;False;0;0;0;False;0;False;0.5;0.275;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;655;896,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;827;1296,-464;Inherit;False;1000.625;572.1662;;9;43;888;891;890;894;904;889;903;1194;Main Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;890;1344,-112;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;1202;592,304;Inherit;False;_CameraDepthTexture.GetDimensions(width, width)@;1;Call;1;True;width;FLOAT;17;InOut;;Inherit;False;DepthCheck;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;17;False;2;FLOAT;0;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;673;1040,-384;Inherit;False;GeneralFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;624,400;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;674;2048,224;Inherit;False;673;GeneralFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;891;1504,-112;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;903;1616,-224;Inherit;False;671;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1203;800,352;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;16;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;975;2208,704;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1194;1808,-224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;714;2336,352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1196;2224,832;Inherit;False;Property;_NormalMapDepthinfluence;Normal Map Depth influence;4;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;888;1696,-112;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;1728,-400;Inherit;False;Property;_WaterColor;WaterColor;1;1;[Header];Create;True;1;MAIN OPTIONS;0;0;False;0;False;0,0.1607843,0.1568628,0;0,0.2078431,0.2039215,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;976;2368,704;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;373;2464,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;904;1936,-224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1195;2496,720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;889;1936,-320;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;978;2592,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;2480,432;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;0.94;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;894;2080,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;549;2336,208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;377;2608,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;2752,352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StickyNoteNode;1130;2928,544;Inherit;False;150;100;Vertex Offset;;1,1,1,1;Tested Vertex Offset via Normal Maps but the texture compression on any Normal map was too janky to implement it, hence why we are using math generated noise which is as smooth as it gets;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;2720,240;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;2480,208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;352;2880,48;Inherit;False;Property;_NormalScaleSecondaryAnimated;Normal Scale Secondary Animated;25;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;353;2896,-48;Inherit;False;Property;_NormalScaleAnimated;Normal Scale Animated;24;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;1193;2944,-144;Inherit;False;Property;_CullMode;Cull Mode;2;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;369;2720,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;2896,128;Inherit;False;Property;_ShaderOptimizerEnabled;PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER;0;0;Create;False;0;0;0;True;1;ShaderOptimizerLockButton;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;966;2896,224;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Deferred;0;3;Deferred;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Deferred;True;2;True;17;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;967;2896,224;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Meta;0;4;Meta;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;963;2896,224;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ExtraPrePass;0;0;ExtraPrePass;6;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;2;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;968;2896,224;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ShadowCaster;0;5;ShadowCaster;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;964;2896,224;Float;False;True;-1;2;ASEMaterialInspector;0;9;Moriohs Shaders/Enviroment Shaders/Sea-Water-simple;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardBase;0;1;ForwardBase;18;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;1193;True;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;False;True;3;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;DisableBatching=False=DisableBatching;True;7;False;0;False;True;1;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;4;Include;;False;;Native;Custom;SamplerState sampler_CameraDepthTexture@;False;;Custom;Custom;Texture2D _CameraDepthTexture@;False;;Custom;Custom;uniform float4 _CameraDepthTexture_TexelSize@;False;;Custom;;0;0;Standard;40;Workflow,InvertActionOnDeselection;1;0;Surface;1;0;  Blend;0;0;  Refraction Model;0;0;  Dither Shadows;0;0;Two Sided;1;0;Deferred Pass;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,-1;0;Translucency;0;0;  Translucency Strength;1,False,-1;0;  Normal Distortion;0.5,False,-1;0;  Scattering;2,False,-1;0;  Direct;0.9,False,-1;0;  Ambient;0.1,False,-1;0;  Shadow;0.5,False,-1;0;Cast Shadows;0;0;  Use Shadow Threshold;0;0;Receive Shadows;0;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;1;0;Ambient Light;1;0;Meta Pass;0;0;Add Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;1;0;  Tess;1,False,-1;0;  Min;1500,False,-1;0;  Max;5000,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Fwd Specular Highlights Toggle;1;0;Fwd Reflections Toggle;1;0;Disable Batching;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;6;False;True;True;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;965;2896,224;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardAdd;0;2;ForwardAdd;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;2;False;0;False;True;4;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
WireConnection;1128;68;383;0
WireConnection;1221;0;1220;1
WireConnection;1221;1;1220;3
WireConnection;625;0;1128;83
WireConnection;1222;0;87;0
WireConnection;1223;0;1222;0
WireConnection;1223;1;1221;0
WireConnection;1223;2;383;0
WireConnection;344;0;346;0
WireConnection;1224;0;1223;0
WireConnection;1224;1;1222;1
WireConnection;1217;1;1218;0
WireConnection;923;0;631;0
WireConnection;923;1;344;0
WireConnection;1215;0;1219;0
WireConnection;924;0;1224;0
WireConnection;924;1;923;0
WireConnection;1214;0;1217;3
WireConnection;1214;1;1216;0
WireConnection;340;0;87;0
WireConnection;340;1;924;0
WireConnection;1213;0;1214;0
WireConnection;1213;1;1215;0
WireConnection;1210;0;1211;2
WireConnection;1210;2;1213;0
WireConnection;1210;3;1212;0
WireConnection;1210;4;1212;0
WireConnection;80;0;1128;0
WireConnection;372;0;340;0
WireConnection;1206;0;372;1
WireConnection;671;0;1210;0
WireConnection;1179;0;648;0
WireConnection;1179;1;1192;0
WireConnection;668;0;646;0
WireConnection;1207;0;1206;0
WireConnection;1190;0;1181;0
WireConnection;1190;1;1191;0
WireConnection;675;0;667;0
WireConnection;675;1;668;0
WireConnection;666;0;1179;0
WireConnection;666;1;667;0
WireConnection;666;2;646;0
WireConnection;1208;0;1207;0
WireConnection;1226;0;1227;0
WireConnection;1226;1;52;0
WireConnection;1189;0;1190;0
WireConnection;1209;0;1208;0
WireConnection;1225;0;1226;0
WireConnection;642;0;666;0
WireConnection;642;1;675;0
WireConnection;1180;0;642;0
WireConnection;1180;1;1189;0
WireConnection;1228;0;1209;0
WireConnection;1228;1;1225;0
WireConnection;1229;0;1228;0
WireConnection;655;0;1180;0
WireConnection;673;0;655;0
WireConnection;54;0;1229;0
WireConnection;54;1;55;0
WireConnection;891;0;890;0
WireConnection;1203;0;1202;2
WireConnection;1203;2;54;0
WireConnection;1194;0;903;0
WireConnection;714;0;1203;0
WireConnection;714;1;674;0
WireConnection;888;0;891;0
WireConnection;976;0;975;0
WireConnection;373;0;714;0
WireConnection;904;0;1194;0
WireConnection;1195;0;976;1
WireConnection;1195;1;1196;0
WireConnection;889;0;43;0
WireConnection;889;1;888;0
WireConnection;978;0;671;0
WireConnection;978;1;1195;0
WireConnection;894;0;43;0
WireConnection;894;1;889;0
WireConnection;894;2;904;0
WireConnection;549;0;674;0
WireConnection;549;1;1203;0
WireConnection;377;0;373;0
WireConnection;374;0;377;0
WireConnection;374;1;39;0
WireConnection;288;0;894;0
WireConnection;288;1;549;0
WireConnection;369;0;978;0
WireConnection;964;0;288;0
WireConnection;964;1;81;0
WireConnection;964;5;374;0
WireConnection;964;7;369;0
ASEEND*/
//CHKSM=733DAA76DBF7B62167A0084B705A6CBCFEA01D99