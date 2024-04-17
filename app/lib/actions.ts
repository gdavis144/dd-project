'use server';
import { z } from 'zod';
import { sql } from '@vercel/postgres';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { signIn } from '@/auth';
import { AuthError } from 'next-auth';
import { executeProcedure } from './data';

const FormSchema = z.object({
  sid: z.string(),
  song_name: z.string({
    invalid_type_error: 'Please enter a song name.',
  }),
  length: z.coerce.number().gt(0, {
    message: 'Please enter a length in seconds.' 
  }),
  cover_image_link: z.string({
    invalid_type_error: 'Please select a cover image.',
  }).optional(),
  streaming_link: z.string({
    invalid_type_error: 'Please enter a streaming link.',
  }).optional(),
  album_id: z.coerce.number().gt(0, { message: 'Please enter a valid album.' }).optional(),
});

export type State = {
  errors?: {
    song_name?: string[];
    length?: string[];
    cover_image_link?: string[];
    streaming_link?: string[];
    album_id?: string[];
  };
  message?: string | null;
};

const CreateInvoice = FormSchema.omit({ sid: true, date: true });

export async function createSong(prevState: State, formData: FormData) {
  // Validate form using Zod
  const validatedFields = CreateInvoice.safeParse({
    song_name: formData.get('song_name'),
    length: formData.get('length'),
    cover_image_link: formData.get('cover_image_link'),
    streaming_link: formData.get('streaming_link'),
  });

  // If form validation fails, return errors early. Otherwise, continue.
  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Missing Fields. Failed to Create Song.',
    };
  }

  // Prepare data for insertion into the database
  const { song_name, length, cover_image_link, streaming_link, album_id } = validatedFields.data;
  const date = new Date().toISOString().split('T')[0];

  // Insert data into the database
  try {
    console.log({ song_name, length, cover_image_link, streaming_link, album_id });
    await executeProcedure(`
    (${song_name}, ${length}, ${date}, ${cover_image_link? cover_image_link: null}, ${streaming_link? streaming_link: null}, ${album_id? album_id : null});`)
  } catch (error) {
    // If a database error occurs, return a more specific error.
    return {
      message: 'Database Error: Failed to Create Song.',
    };
  }

  // Revalidate the cache for the invoices page and redirect the user.
  revalidatePath('/dashboard/songs');
  redirect('/dashboard/songs');
}

const UpdateSong = FormSchema.omit({ id: true, date: true });

export async function updateSong(id: string, formData: FormData) {
  const {
    song_name,
    cover_image_link,
    length,
    streaming_link,
    album_id,
  } = UpdateSong.parse({
    song_name: formData.get('song_name'),
    cover_image_link: formData.get('cover_image_link'),
    length: formData.get('length'),
    streaming_link: formData.get('streaming_link'),
    album_id: formData.get('album_id'),
  });

  try {
    await sql`
          UPDATE song
          SET length = ${length}, song_name = ${song_name}, cover_image_link = ${cover_image_link}, streaming_link = ${streaming_link},
          album_id = ${album_id}
          WHERE id = ${id}
        `;
  } catch (error) {
    return { message: 'Database Error: Failed to Update Invoice.' };
  }

  revalidatePath('/dashboard/invoices');
  redirect('/dashboard/invoices');
}

export async function deleteSong(id: string) {
  try {
    await sql`DELETE FROM invoices WHERE id = ${id}`;
    revalidatePath('/dashboard/invoices');
    return { message: 'Deleted Invoice.' };
  } catch (error) {
    return { message: 'Database Error: Failed to Delete Invoice.' };
  }
}

export async function followArtist(follower_id: string, artist_id: number) {
  try {
    await sql`call`;
    revalidatePath(`/dashboard/users/${artist_id}`);
    return { message: 'Followed artist.' };
  } catch (error) {
    return { message: 'Database Error: Failed to follow artist.' };
  }
}

export async function authenticate(
  prevState: string | undefined,
  formData: FormData,
) {
  try {
    await signIn('credentials', formData);
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return 'Invalid credentials.';
        default:
          return 'Something went wrong.';
      }
    }
    throw error;
  }
}
