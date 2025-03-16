
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(supabaseUrl, supabaseKey);

export type NGO = {
  id: string;
  ngo_name: string;
  address: string;
  administrator_name: string;
  email: string;
  phone_number: string | null;
  darpan_id: string;
  logo_url: string | null;
};

export type Campaign = {
  id: string;
  campaign_name: string;
  campaign_description: string;
  image_url: string | null;
  ngo_id: string;
  funds_required: number;
  funds_collected: number | null;
  is_completed: boolean;
  campign_proposal: string | null;
  valid_until: string | null;
};

export type Milestone = {
  id: string;
  campaign_id: string;
  milestone_name: string;
  description: string;
  target_date: string;
  funding_required: number | null;
  is_verified: boolean;
  document_url: string | null;
  created_at: string | null;
};

export type CampaignMilestone = {
  id: string;
  campaign_id: string;
  milestone_name: string;
  description: string;
  target_date: string;
  funding_required: number | null;
  is_verified: boolean;
  document_url: string | null;
  created_at: string | null;
  votecount: number | null;
};
